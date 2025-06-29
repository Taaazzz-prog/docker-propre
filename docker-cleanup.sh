#!/bin/bash

# Affiche un message d'explication en vert au lancement du script
echo -e "\033[1;32m
Script : docker-cleanup.sh

Fonctionnement :
- Si un nom d'image Docker est passé en argument, le script arrête et supprime tous les conteneurs utilisant cette image, puis supprime l'image elle-même.
- Si aucun argument n'est fourni, le script nettoie toutes les images Docker non étiquetées (<none>), généralement des couches obsolètes.

Utilisation :
1. Pour supprimer une image spécifique (et ses conteneurs) :
   ./docker-cleanup.sh nom_image

   Exemple :
   ./docker-cleanup.sh mon_image:latest

2. Pour nettoyer toutes les images non étiquetées :
   ./docker-cleanup.sh
\033[0m"

# Affiche un message d'information avec une couleur bleue
info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

# Affiche un message de succès avec une couleur verte
success() {
    echo -e "\033[1;32m[SUCCÈS]\033[0m $1"
}

# Vérifie si un nom d'image est passé en argument
if [ -n "$1" ]; then
    IMAGE_NAME=$1
    info "Tentative de suppression des conteneurs et de l'image pour '$IMAGE_NAME'..."

    # Trouve et arrête les conteneurs utilisant l'image
    CONTAINER_IDS=$(docker ps -a --filter "ancestor=$IMAGE_NAME" -q)

    if [ -n "$CONTAINER_IDS" ]; then
        info "Arrêt des conteneurs : $CONTAINER_IDS"
        docker stop $CONTAINER_IDS
        info "Suppression des conteneurs : $CONTAINER_IDS"
        docker rm $CONTAINER_IDS
    else
        info "Aucun conteneur en cours d'exécution trouvé pour l'image '$IMAGE_NAME'."
    fi

    # Supprime l'image Docker
    info "Suppression de l'image Docker '$IMAGE_NAME'..."
    docker rmi $IMAGE_NAME

    success "Opération terminée pour l'image '$IMAGE_NAME'."
else
    info "Ce script va supprimer toutes les images Docker non étiquetées (marquées comme <none>)."
    info "Ces images sont généralement des couches de construction obsolètes et peuvent être supprimées en toute sécurité."
    echo

    # La commande 'docker image prune' est conçue spécifiquement pour cela.
    # Elle demande une confirmation avant de supprimer quoi que ce soit.
    docker image prune

    echo
    success "Le nettoyage des images Docker non étiquetées est terminé."
fi