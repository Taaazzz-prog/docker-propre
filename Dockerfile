# Utiliser une image de base Node.js officielle
FROM node:20-alpine

# Arguments pour l'UID et le GID de l'utilisateur hôte
ARG UID=1000
ARG GID=1000

# Définir le répertoire de travail dans le conteneur
WORKDIR /usr/src/app

# Créer un groupe et un utilisateur 'node' avec les UID/GID de l'hôte
RUN deluser --remove-home node && \
    addgroup -g $GID -S node && \
    adduser -u $UID -S node -G node

# Copier le script d'installation et changer son propriétaire
COPY --chown=node:node setup.sh .

# Installer bash car le script setup.sh l'utilise
RUN apk add --no-cache bash git su-exec && \
    git config --global user.email "docker@example.com" && \
    git config --global user.name "Docker"

# Rendre le script exécutable
RUN chmod +x setup.sh

# Changer le propriétaire du répertoire de travail
RUN chown -R node:node /usr/src/app

# Changer d'utilisateur pour un utilisateur non-root

# Exécuter le script de configuration pendant la phase de construction de l'image.
# Cela installe toutes les dépendances et configure le projet.
# Le script setup.sh sera maintenant exécuté au démarrage via docker-compose
# pour fonctionner correctement avec les volumes.

# Exposer les ports pour Angular (4200) and Express (3000)
EXPOSE 4200
EXPOSE 3000

# La commande par défaut pour démarrer le conteneur.
# 'npm start' utilisera 'concurrently' pour lancer le backend et le frontend.
CMD ["npm", "start"]