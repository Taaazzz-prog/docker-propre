# Documentation d'Installation Personnalisée du Projet Docker

Ce document détaille l'architecture du projet conteneurisé et explique comment utiliser le script d'installation interactif pour configurer et lancer votre environnement de développement.

## 1. Architecture et Personnalisation

Le projet utilise Docker et Docker Compose pour créer un environnement de développement complet et isolé. L'architecture est conçue pour être flexible grâce à un système de configuration basé sur des variables d'environnement.

### Fichiers Clés

-   **`install.sh`**: **Le point d'entrée principal.** C'est un script interactif qui vous guide dans la configuration de votre projet. Il vérifie les ports disponibles sur votre machine, vous demande de nommer votre application et génère le fichier de configuration `.env` avant de lancer les conteneurs.
-   **`.env.example`**: Un fichier modèle qui contient toutes les variables de configuration possibles avec des valeurs par défaut.
-   **`.env`**: Le fichier de configuration personnel, **généré par `install.sh`**. Ce fichier est lu par `docker-compose` pour configurer l'environnement. **Il ne doit pas être versionné (ajouté à `.gitignore`)**.
-   **`docker-compose.yml`**: Le chef d'orchestre. Il utilise les variables du fichier `.env` pour configurer les ports, les noms et les dépendances des services.
-   **`Dockerfile`**: La recette pour construire l'image Docker de l'application.
-   **`setup.sh`**: Un script exécuté **à l'intérieur du conteneur Docker** lors du premier démarrage. Il utilise les variables d'environnement (comme `APP_NAME`) pour installer et configurer dynamiquement Angular, Node.js, et les autres dépendances.

## 2. Comment Lancer le Projet (Méthode Recommandée)

**Prérequis**: Avoir Docker et Docker Compose installés sur votre machine.

1.  **Rendre le script exécutable (si nécessaire)**:
    Si vous venez de cloner le projet, assurez-vous que le script `install.sh` est exécutable.

    ```bash
    chmod +x install.sh
    ```

2.  **Lancer l'installation interactive**:
    Exécutez le script `install.sh` depuis votre terminal.

    ```bash
    ./install.sh
    ```

3.  **Suivre les instructions**:
    Le script va vous poser plusieurs questions :
    -   **Nom de l'application**: Choisissez un nom pour votre projet Angular (ex: `mon-super-projet`).
    -   **Ports**: Le script vérifiera si les ports par défaut (4200, 3000, 27018) sont disponibles. Si un port est déjà utilisé, il vous en proposera un autre et vous demandera de confirmer.

4.  **Lancement automatique**:
    Une fois la configuration terminée, le script génère le fichier `.env` et lance automatiquement `docker compose up --build -d`. Les conteneurs démarreront en arrière-plan.

5.  **Accéder aux applications**:
    Le script vous affichera les URLs et ports finaux pour accéder à vos services :
    -   **Frontend (Angular)**: `http://localhost:<VOTRE_PORT_FRONTEND>`
    -   **Backend (API)**: `http://localhost:<VOTRE_PORT_BACKEND>/api`
    -   **Base de données (MongoDB)**: `localhost:<VOTRE_PORT_MONGO>`

## 3. Commandes Utiles

Une fois l'environnement lancé, vous pouvez utiliser les commandes `docker-compose` standards :

-   **Voir les logs en direct**:
    ```bash
    docker compose logs -f
    ```

-   **Arrêter les conteneurs**:
    ```bash
    docker compose down
    ```

-   **Arrêter et supprimer les volumes de données (réinitialisation complète)**:
    ```bash
    docker compose down -v
    ```

## 4. Développement

Le développement reste identique : modifiez vos fichiers localement, et les changements seront synchronisés dans le conteneur et rechargés à chaud grâce aux volumes et à `nodemon`/`ng serve`.