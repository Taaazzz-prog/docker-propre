#!/bin/bash

# --- Fonctions Utilitaires ---

# Affiche un message d'information
info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

# Affiche un message de succès
success() {
    echo -e "\033[1;32m[SUCCÈS]\033[0m $1"
}

# Affiche un message d'erreur et quitte

error() {
    echo -e "\033[1;31m[ERREUR]\033[0m $1" >&2
    exit 1
}

# Vérifie si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Vérifie si un port est déjà utilisé sur la machine hôte
is_port_in_use() {
    local port=$1
    # Utilise netstat ou ss, selon ce qui est disponible
    if command_exists netstat; then
        netstat -tuln | grep ":$port " >/dev/null
    elif command_exists ss; then
        ss -tuln | grep ":$port " >/dev/null
    else
        info "Ni 'netstat' ni 'ss' n'ont été trouvés. Impossible de vérifier les ports."
        return 1 # On ne peut pas vérifier, on suppose que le port est libre
    fi
}

# Demande à l'utilisateur un port, en vérifiant sa disponibilité
prompt_for_port() {
    local port_var_name=$1
    local default_port=$2
    local prompt_message=$3
    local new_port

    while true; do
        read -p "$prompt_message [$default_port]: " new_port
        new_port=${new_port:-$default_port} # Utilise la valeur par défaut si l'entrée est vide

        if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
            echo "Veuillez entrer un numéro de port valide (1-65535)."
        elif is_port_in_use "$new_port"; then
            echo "Le port $new_port est déjà utilisé. Veuillez en choisir un autre."
            default_port=$((new_port + 1)) # Suggère le port suivant
        else
            eval "$port_var_name=$new_port"
            break
        fi
    done
}

# Vérifie si un nom de conteneur Docker est déjà utilisé
is_container_name_in_use() {
    local name=$1
    # Recherche un conteneur existant (même stoppé) avec ce nom exact.
    # La commande retourne le nom du conteneur s'il est trouvé, sinon une chaîne vide.
    if [ -n "$(docker ps -a --filter "name=^/${name}$" --format '{{.Names}}')" ]; then
        return 0 # Le nom est utilisé (succès pour la condition if)
    else
        return 1 # Le nom est libre
    fi
    if ! docker info >/dev/null 2>&1; then
        error "Le daemon Docker ne semble pas fonctionner. Veuillez le démarrer avant de continuer."
    fi
}

# Demande à l'utilisateur un nom de conteneur, en vérifiant sa disponibilité
prompt_for_container_name() {
    local var_name=$1
    local default_name=$2
    local prompt_message=$3
    local new_name

    while true; do
        read -p "$prompt_message [$default_name]: " new_name
        new_name=${new_name:-$default_name} # Utilise la valeur par défaut si l'entrée est vide

        if is_container_name_in_use "$new_name"; then
            echo -e "\033[1;33m[ATTENTION]\033[0m Le nom de conteneur '$new_name' est déjà utilisé. Veuillez en choisir un autre."
            # Suggère un nouveau nom en ajoutant un suffixe
            default_name="${new_name}-alt"
        else
            eval "$var_name=\$$new_name"
            break
        fi
    done
}

# --- Début du Script d'Installation ---

info "Bienvenue dans l'installateur de projet personnalisé."
info "Ce script va vous aider à configurer votre environnement."

# Vérification des prérequis
if ! command_exists docker; then
    error "Docker n'est pas installé. Veuillez l'installer avant de continuer."
fi
if ! command_exists docker compose; then
    error "Docker Compose n'est pas installé. Veuillez l'installer avant de continuer."
fi

# Copie de .env.example vers .env s'il n'existe pas
if [ ! -f ".env" ]; then
    info "Création du fichier de configuration .env à partir de l'exemple."
    cp .env.example .env
else
    info "Le fichier .env existe déjà. Utilisation de la configuration existante comme base."
fi

# Chargement des variables depuis .env.example pour les valeurs par défaut
source .env.example

# --- Configuration Interactive ---

# Nom de l'application
read -p "Entrez le nom de votre application Angular [$APP_NAME]: " new_app_name
APP_NAME=${new_app_name:-$APP_NAME}

# Ports
prompt_for_port FRONTEND_PORT $FRONTEND_PORT "Entrez le port pour le frontend (Angular)"
prompt_for_port BACKEND_PORT $BACKEND_PORT "Entrez le port pour le backend (Express)"
prompt_for_port MONGO_PORT $MONGO_PORT "Entrez le port pour la base de données (MongoDB)"

# Noms des conteneurs
prompt_for_container_name APP_CONTAINER_NAME "${APP_CONTAINER_NAME:-my-app-container}" "Entrez le nom pour le conteneur de l'application"
prompt_for_container_name MONGO_CONTAINER_NAME "${MONGO_CONTAINER_NAME:-my-mongo-container}" "Entrez le nom pour le conteneur de la base de données"

# --- Génération du Fichier .env ---

info "Génération du fichier .env avec votre configuration..."

cat > .env << EOL
# Fichier d'environnement généré par install.sh
APP_NAME=${APP_NAME}
FRONTEND_PORT=${FRONTEND_PORT}
BACKEND_PORT=${BACKEND_PORT}
MONGO_PORT=${MONGO_PORT}
APP_CONTAINER_NAME=${APP_CONTAINER_NAME}
MONGO_CONTAINER_NAME=${MONGO_CONTAINER_NAME}
EOL

success "Fichier .env généré avec succès !"
echo "----------------------------------------"
cat .env
echo "----------------------------------------"

# --- Lancement de Docker Compose ---

info "Lancement de l'environnement Docker..."
info "La première fois, cela peut prendre plusieurs minutes pour tout installer."

# Lancement et vérification
if ! docker compose up --build -d; then
    error "Le lancement de Docker Compose a échoué. Vérifiez les messages d'erreur ci-dessus."
fi

info "Attente de la stabilisation des conteneurs (15 secondes)..."
sleep 15

# Vérification de l'état des conteneurs après le lancement
services=("app" "mongo")
all_running=true
for service in "${services[@]}"; do
    # Récupère le nom du conteneur à partir du service Docker Compose
    container_name=$(docker compose ps -q "$service")
    if [ -z "$container_name" ]; then
        error "Impossible de trouver le conteneur pour le service '$service'."
        all_running=false
        continue
    fi

    # Vérifie si le conteneur est en cours d'exécution
    if ! docker inspect -f '{{.State.Running}}' "$container_name" | grep "true" > /dev/null; then
        echo
        error "Le service '$service' n'a pas démarré correctement."
        info "Voici les derniers logs du conteneur pour vous aider à diagnostiquer :"
        echo "-------------------- LOGS DE $service --------------------"
        docker logs "$container_name" --tail 50
        echo "---------------------------------------------------"
        all_running=false
    fi
done

if [ "$all_running" = true ]; then
    success "L'environnement a été lancé et tous les services sont opérationnels !"
    info "Pour voir les logs en direct, utilisez : docker compose logs -f"
    info "Pour arrêter l'environnement, utilisez : docker compose down"
    echo
    info "--- Accès ---"
    info "Frontend (Angular): http://localhost:${FRONTEND_PORT}"
    info "Backend (API): http://localhost:${BACKEND_PORT}/api"
    info "MongoDB: localhost:${MONGO_PORT}"
else
    error "Certains services n'ont pas pu démarrer. Veuillez corriger les erreurs ci-dessus et relancer."
fi