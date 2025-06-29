#!/bin/bash

# Fonction pour logger les actions
log_action() {
    echo "=========================================================="
    echo "=> $1"
    echo "=========================================================="
}

# Fonction pour exécuter une commande avec gestion d'erreur
run_command() {
    local description=$1
    local command_to_run=$2

    log_action "Début : $description"
    
    # Exécute la commande. Si elle échoue, affiche un message et quitte le script.
    if ! eval "$command_to_run"; then
        log_action "ÉCHEC : $description"
        exit 1
    fi
    
    log_action "Succès : $description"
}

# --- DÉBUT DU SCRIPT D'INSTALLATION ---

# Vérifier si le package.json existe déjà pour éviter de réinitialiser
if [ ! -f "package.json" ]; then
    run_command "Initialisation du projet Node.js" "npm init -y"
else
    log_action "Projet Node.js déjà initialisé. Saut de l'étape."
fi

run_command "Installation du serveur Express, Mongoose et CORS" "npm install express mongoose cors"
run_command "Installation des dépendances de développement (serveur et utilitaires)" "npm install -D typescript @types/node @types/express ts-node nodemon concurrently @angular/cli"

# Création d'un tsconfig.json pour le backend
run_command "Création du fichier de configuration TypeScript (tsconfig.json)" "npx tsc --init --rootDir src --outDir dist --lib es6 --module commonjs --resolveJsonModule true"

# Installation d'Angular
# On n'installe plus globalement pour éviter les problèmes de permissions et de versioning
# run_command "Installation d'Angular CLI" "npm install -g @angular/cli"

# Vérifier si le projet Angular existe déjà
# Utilise la variable d'environnement APP_NAME, avec "frontend" comme valeur par défaut
APP_NAME=${APP_NAME:-frontend}

if [ ! -d "$APP_NAME" ]; then
    run_command "Création du projet Angular '$APP_NAME'" "npx ng new $APP_NAME --directory ./$APP_NAME --routing --style=css --skip-install"
else
    log_action "Projet Angular '$APP_NAME' déjà existant. Saut de l'étape."
fi

# Aller dans le dossier de l'application pour installer les dépendances
cd $APP_NAME

run_command "Installation des dépendances pour Angular" "npm install"
run_command "Installation des dépendances de Tailwind CSS (v3)" "npm install -D tailwindcss@^3.0.0 postcss@^8.0.0 autoprefixer@^10.0.0"
# Revenir au répertoire racine
cd ..

log_action "Configuration de Tailwind CSS..."
# Configuration de tailwind.config.js
cat > ./${APP_NAME}/tailwind.config.js << EOL
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# Configuration de postcss.config.js
cat > ./${APP_NAME}/postcss.config.js << EOL
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

# Configuration de styles.css pour inclure Tailwind
cat > ./${APP_NAME}/src/styles.css << EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

log_action "Création d'un serveur Express de base..."
mkdir -p src
cat > ./src/server.ts << EOL
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/mydatabase';

mongoose.connect(mongoUri)
  .then(() => console.log('Connexion à MongoDB réussie !'))
  .catch(err => console.error('Erreur de connexion à MongoDB:', err));

app.get('/api', (req, res) => {
  res.send('Serveur Express avec TypeScript fonctionne !');
});

app.listen(port, () => {
  console.log(\`Serveur démarré sur http://localhost:\${port}\`);
});
EOL

log_action "Mise à jour du package.json avec les scripts de lancement"
# Utilise node pour manipuler le JSON de manière plus sûre
node -e "let pkg = require('./package.json'); \
         pkg.scripts = { \
           ...pkg.scripts, \
           'start': 'concurrently \\"npm:start:backend\\" \\"npm:start:frontend\\"', \
           'start:backend': 'nodemon --watch src --exec ts-node src/server.ts', \
           'start:frontend': 'cd ' + (process.env.APP_NAME || 'frontend') + ' && ng serve --host 0.0.0.0 --port 4200 --disable-host-check', \
           'build:backend': 'tsc', \
           'postinstall': 'cd ' + (process.env.APP_NAME || 'frontend') + ' && npm install' \
         }; \
         require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));"


# --- FIN DU SCRIPT ---
log_action "INSTALLATION TERMINÉE AVEC SUCCÈS !"
log_action "L'image est prête. La commande 'npm start' lancera les serveurs."