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

# Valide le format d'un nom de conteneur Docker
is_valid_container_name() {
    local name=$1
    # Doit commencer par une lettre ou un chiffre, et ne contenir que des lettres, chiffres, tirets, underscores ou points.
    if [[ "$name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]+$ ]]; then
        return 0 # Valide
    else
        return 1 # Invalide
    fi
}

# Vérifie si un nom de conteneur Docker est déjà utilisé
is_container_name_in_use() {
    local name=$1
    if [ -n "$(docker ps -a --filter "name=^/${name}$" --format '{{.Names}}')" ]; then
        return 0 # Le nom est utilisé
    else
        return 1 # Le nom est libre
    fi
}

# Demande à l'utilisateur un nom de conteneur, en vérifiant sa disponibilité
prompt_for_container_name() {
    local default_name=$1
    local prompt_message=$2
    local new_name

    while true; do
        read -p "$prompt_message [$default_name]: " new_name
        new_name=${new_name:-$default_name} # Utilise la valeur par défaut si l'entrée est vide

        if ! is_valid_container_name "$new_name"; then
            echo -e "\033[1;31m[ERREUR]\033[0m Nom de conteneur invalide. Il doit commencer par une lettre ou un chiffre et ne peut contenir que des lettres, chiffres, '_', '.' ou '-'."
        elif is_container_name_in_use "$new_name"; then
            echo -e "\033[1;33m[ATTENTION]\033[0m Le nom de conteneur '$new_name' est déjà utilisé. Veuillez en choisir un autre."
            default_name="${new_name}-alt"
        else
            printf "%s" "$new_name" # Retourne le nom validé
            break
        fi
    done
}

# Trouve un port disponible en commençant par un port de base
find_available_port() {
    local port=$1
    while is_port_in_use "$port"; do
        # Redirige le message d'info vers stderr pour ne pas être capturé par $()
        info "Le port $port est déjà utilisé. Recherche du prochain port disponible..." >&2
        port=$((port + 1))
    done
    echo "$port" # Seul le numéro de port est envoyé à stdout
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

read -p "Voulez-vous utiliser la configuration interactive ? (o/N) " use_interactive
use_interactive=${use_interactive:-n}

if [[ "$use_interactive" =~ ^[oO](ui)?$ ]]; then
    # Demander le nom de l'application
    read -p "Entrez le nom de votre application [${APP_NAME:-my-angular-app}]: " new_app_name
    APP_NAME=${new_app_name:-${APP_NAME:-my-angular-app}}

    # Demander le nom de la base de données
    read -p "Entrez le nom de la base de données [${MONGO_DB_NAME:-mydatabase}]: " new_db_name
    MONGO_DB_NAME=${new_db_name:-${MONGO_DB_NAME:-mydatabase}}

    # Demander les noms des conteneurs
    APP_CONTAINER_NAME=$(prompt_for_container_name "${APP_CONTAINER_NAME:-${APP_NAME}-app}" "Entrez le nom du conteneur pour l'application")
    MONGO_CONTAINER_NAME=$(prompt_for_container_name "${MONGO_CONTAINER_NAME:-${APP_NAME}-mongo}" "Entrez le nom du conteneur pour MongoDB")

    # Demander les ports
    prompt_for_port FRONTEND_PORT "${FRONTEND_PORT:-4200}" "Entrez le port pour le frontend (Angular)"
    prompt_for_port BACKEND_PORT "${BACKEND_PORT:-3000}" "Entrez le port pour le backend (Express)"
    prompt_for_port MONGO_PORT "${MONGO_PORT:-27018}" "Entrez le port pour la base de données (MongoDB)"
else
    info "Utilisation de la configuration par défaut."
    APP_NAME=${APP_NAME:-my-angular-app}
    MONGO_DB_NAME=${MONGO_DB_NAME:-mydatabase}
    APP_CONTAINER_NAME=${APP_CONTAINER_NAME:-my-app-container}
    MONGO_CONTAINER_NAME=${MONGO_CONTAINER_NAME:-my-mongo-container}
    FRONTEND_PORT=${FRONTEND_PORT:-4200}
    BACKEND_PORT=${BACKEND_PORT:-3000}
    MONGO_PORT=${MONGO_PORT:-27018}
fi

# Vérification et ajustement automatique des ports
info "Vérification de la disponibilité des ports..."
ORIGINAL_FRONTEND_PORT=${FRONTEND_PORT:-4200}
FRONTEND_PORT=$(find_available_port "$ORIGINAL_FRONTEND_PORT")
if [ "$FRONTEND_PORT" != "$ORIGINAL_FRONTEND_PORT" ]; then
    info "Le port frontend a été ajusté à \033[1;33m$FRONTEND_PORT\033[0m car le port $ORIGINAL_FRONTEND_PORT était occupé."
fi

ORIGINAL_BACKEND_PORT=${BACKEND_PORT:-3000}
BACKEND_PORT=$(find_available_port "$ORIGINAL_BACKEND_PORT")
if [ "$BACKEND_PORT" != "$ORIGINAL_BACKEND_PORT" ]; then
    info "Le port backend a été ajusté à \033[1;33m$BACKEND_PORT\033[0m car le port $ORIGINAL_BACKEND_PORT était occupé."
fi

ORIGINAL_MONGO_PORT=${MONGO_PORT:-27018}
MONGO_PORT=$(find_available_port "$ORIGINAL_MONGO_PORT")
if [ "$MONGO_PORT" != "$ORIGINAL_MONGO_PORT" ]; then
    info "Le port Mongo a été ajusté à \033[1;33m$MONGO_PORT\033[0m car le port $ORIGINAL_MONGO_PORT était occupé."
fi

# --- Génération du Fichier .env ---

info "Génération du fichier .env avec votre configuration..."

cat > .env << EOL
# Fichier d'environnement généré par install.sh
APP_NAME=${APP_NAME}
FRONTEND_PORT=${FRONTEND_PORT}
BACKEND_PORT=${BACKEND_PORT}
MONGO_PORT=${MONGO_PORT}
MONGO_DB_NAME=${MONGO_DB_NAME:-mydatabase}
APP_CONTAINER_NAME=${APP_CONTAINER_NAME:-my-app-container}
MONGO_CONTAINER_NAME=${MONGO_CONTAINER_NAME:-my-mongo-container}
EOL

success "Fichier .env généré avec succès !"
echo "----------------------------------------"
cat .env
echo "----------------------------------------"

# --- Lancement de Docker Compose ---

info "Nettoyage de tout environnement Docker précédent..."
# L'option --remove-orphans supprime les conteneurs pour les services qui n'existent plus dans le fichier compose.
# L'option -v supprime les volumes nommés.
docker compose down --remove-orphans -v

# Forcer la suppression des conteneurs s'ils existent
if [ -n "$(docker ps -a -q -f name=^/${APP_CONTAINER_NAME}$)" ]; then
    info "Suppression du conteneur existant : ${APP_CONTAINER_NAME}"
    docker rm -f "${APP_CONTAINER_NAME}"
fi
if [ -n "$(docker ps -a -q -f name=^/${MONGO_CONTAINER_NAME}$)" ]; then
    info "Suppression du conteneur existant : ${MONGO_CONTAINER_NAME}"
    docker rm -f "${MONGO_CONTAINER_NAME}"
fi

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
    # On tente d'exécuter une commande simple dans le service.
    # Si elle échoue, le service n'est pas prêt.
    if ! docker compose exec "$service" echo "Vérification du service $service..." > /dev/null 2>&1; then
        echo
        error "Le service '$service' n'a pas répondu correctement."
        info "Voici les derniers logs du conteneur pour vous aider à diagnostiquer :"
        echo "-------------------- LOGS DE $service --------------------"
        # On récupère l'ID du conteneur pour les logs
        container_id=$(docker compose ps -q "$service")
        if [ -n "$container_id" ]; then
            docker logs "$container_id" --tail 50
        else
            echo "Impossible de récupérer les logs pour le service '$service'."
        fi
        echo "---------------------------------------------------"
        all_running=false
    else
        success "Le service '$service' est opérationnel."
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