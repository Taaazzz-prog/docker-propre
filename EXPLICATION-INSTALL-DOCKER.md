# Documentation d'Installation et d'Architecture du Projet Docker

Ce document détaille l'architecture du projet conteneurisé avec Docker et fournit les étapes nécessaires pour son installation et son lancement.

## 1. Architecture Globale

Le projet est composé de deux services principaux, orchestrés par `docker-compose`:

1.  **`app`**: Le conteneur principal qui héberge à la fois le **backend** (serveur Node.js/Express) et le **frontend** (application Angular).
2.  **`mongo`**: Un conteneur qui exécute une instance de la base de données **MongoDB**, utilisée par le backend.

### Fichiers Clés

-   **`Dockerfile`**: La "recette" pour construire l'image Docker du service `app`. Il part d'une image Node.js, copie les fichiers nécessaires et lance un script d'installation.
-   **`docker-compose.yml`**: Le "chef d'orchestre". Il définit les services (`app`, `mongo`), configure leurs relations (dépendances, réseaux), les ports et les volumes de données.
-   **`setup.sh`**: Un script shell exécuté au premier démarrage du conteneur `app`. Il installe toutes les dépendances et configure l'environnement de développement (Node.js, TypeScript, Angular, Tailwind CSS).

## 2. Processus d'Installation (décrit par `setup.sh`)

Lorsque vous lancez l'environnement pour la première fois avec `docker-compose up`, le conteneur `app` exécute le script `setup.sh`. Voici ce qu'il fait, dans l'ordre :

1.  **Initialisation du projet Node.js**:
    -   Vérifie si un `package.json` existe. Si non, il exécute `npm init -y` pour en créer un.

2.  **Installation des dépendances du Backend**:
    -   Installe les bibliothèques principales : `express`, `mongoose` (pour interagir avec MongoDB) et `cors` (pour la gestion des requêtes cross-origin).
    -   Installe les dépendances de développement pour TypeScript : `typescript`, `@types/node`, `@types/express`, `ts-node` (pour exécuter du TypeScript directement) et `nodemon` (pour redémarrer le serveur automatiquement lors de modifications).

3.  **Configuration de TypeScript (Backend)**:
    -   Crée un fichier `tsconfig.json` avec une configuration de base pour le projet backend.

4.  **Installation d'Angular**:
    -   Installe **Angular CLI** de manière globale (`-g`) à l'intérieur du conteneur.
    -   Vérifie si un dossier `frontend` existe. Si non, il crée un nouveau projet Angular avec `ng new frontend`.

5.  **Installation des dépendances du Frontend**:
    -   Se déplace dans le dossier `frontend`.
    -   Exécute `npm install` pour télécharger toutes les dépendances d'Angular.
    -   Installe **Tailwind CSS** et ses dépendances (`postcss`, `autoprefixer`) et crée son fichier de configuration `tailwind.config.js`.

6.  **Configuration de Tailwind CSS**:
    -   Configure le fichier `tailwind.config.js` pour qu'il scanne les fichiers HTML et TypeScript du projet Angular.
    -   Modifie le fichier `styles.css` d'Angular pour y inclure les directives de base de Tailwind.

7.  **Création du Serveur Express**:
    -   Crée un dossier `src` pour le code source du backend.
    -   Crée un fichier `src/server.ts` contenant un serveur Express de base qui :
        -   Se connecte à la base de données MongoDB (l'URI est fournie par `docker-compose`).
        -   Expose une route simple `/api`.
        -   Écoute sur le port 3000.

8.  **Configuration des Scripts de Lancement**:
    -   Ajoute des scripts au `package.json` pour lancer facilement le backend et le frontend :
        -   `start:backend`: Lance le serveur Express avec `nodemon` et `ts-node`.
        -   `start:frontend`: Lance le serveur de développement Angular.
        -   `build:backend`: Compile le code TypeScript du backend.

## 3. Comment Lancer le Projet

**Prérequis**: Avoir Docker et Docker Compose installés sur votre machine.

1.  **Construire et démarrer les conteneurs**:
    Ouvrez un terminal à la racine du projet (là où se trouve le `docker-compose.yml`) et exécutez la commande suivante :

    ```bash
    docker-compose up --build
    ```

    -   `--build` force la reconstruction de l'image `app` si le `Dockerfile` a changé.
    -   La première fois, cela prendra plusieurs minutes car le script `setup.sh` va tout installer. Les lancements suivants seront beaucoup plus rapides.

2.  **Accéder aux applications**:
    Une fois les conteneurs démarrés :
    -   **Frontend (Angular)**: Ouvrez votre navigateur et allez à l'adresse [http://localhost:4200](http://localhost:4200)
    -   **Backend (Express)**: Vous pouvez tester l'API à l'adresse [http://localhost:3000/api](http://localhost:3000/api)
    -   **Base de données (MongoDB)**: Vous pouvez vous connecter à la base de données via un client comme MongoDB Compass en utilisant l'adresse `localhost` et le port `27018`.

3.  **Arrêter les conteneurs**:
    Pour arrêter les conteneurs, appuyez sur `Ctrl + C` dans le terminal où `docker-compose up` est en cours d'exécution. Pour les supprimer et nettoyer les volumes, vous pouvez utiliser :

    ```bash
    docker-compose down -v
    ```

## 4. Développement

Grâce à la configuration des volumes dans `docker-compose.yml`, tous les fichiers de votre machine locale sont synchronisés avec le conteneur `app`.

-   Vous pouvez modifier le code du backend ou du frontend avec votre éditeur de code préféré.
-   Les modifications du backend seront automatiquement prises en compte grâce à `nodemon`.
-   Les modifications du frontend seront automatiquement prises en compte par le serveur de développement Angular. Vous verrez les changements en direct dans votre navigateur.