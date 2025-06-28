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

# --- Génération du Fichier .env ---

info "Génération du fichier .env avec votre configuration..."

cat > .env << EOL
# Fichier d'environnement généré par install.sh
APP_NAME=${APP_NAME}
FRONTEND_PORT=${FRONTEND_PORT}
BACKEND_PORT=${BACKEND_PORT}
MONGO_PORT=${MONGO_PORT}
EOL

success "Fichier .env généré avec succès !"
echo "----------------------------------------"
cat .env
echo "----------------------------------------"

# --- Lancement de Docker Compose ---

info "Lancement de l'environnement Docker..."
info "La première fois, cela peut prendre plusieurs minutes pour tout installer."

docker compose up --build -d

if [ $? -eq 0 ]; then
    success "L'environnement a été lancé avec succès en arrière-plan (-d)!"
    info "Pour voir les logs, utilisez la commande : docker compose logs -f"
    info "Pour arrêter l'environnement, utilisez : docker compose down"
    echo
    info "--- Accès ---"
    info "Frontend (Angular): http://localhost:${FRONTEND_PORT}"
    info "Backend (API): http://localhost:${BACKEND_PORT}/api"
    info "MongoDB: localhost:${MONGO_PORT}"
else
    error "Une erreur est survenue lors du lancement de docker compose."
fi