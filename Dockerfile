# Utiliser une image de base Node.js officielle
FROM node:20-alpine

# Définir le répertoire de travail dans le conteneur
WORKDIR /usr/src/app

# Copier le script d'installation
COPY setup.sh .

# Rendre le script exécutable
RUN chmod +x setup.sh

# Exposer les ports pour Angular (4200) and Express (3000)
EXPOSE 4200
EXPOSE 3000

# Lancer le script d'installation quand le conteneur démarre
CMD ["./setup.sh"]