# Bienvenue sur notre Projet ! 👋

Salut à toi, futur codeur en herbe ou pas !

Si tu es ici, c'est probablement que tu veux lancer ton application. La bonne nouvelle ? j'ai (je pense) tout fait pour que ce soit le plus simple et le plus agréable possible, même si tu n'es pas un expert de Docker.

Ce document est ton guide. Je vais tout t'expliquer, pas à pas.

## C'est quoi, ce projet ? (La Vision d'Ensemble)

Avant de plonger dans la technique, comprenons ce qu'on met en place. Ce projet est une application web complète qui repose sur plusieurs briques technologiques :

*   **Un Frontend en Angular** : C'est l'interface utilisateur, ce que tu vois et avec quoi tu interagis dans ton navigateur.
*   **Un Backend en Node.js (avec Express)** : C'est le cerveau de l'application. Il gère la logique, les données et communique avec la base de données.
*   **Une Base de données MongoDB** : C'est la mémoire de notre application, là où toutes les informations sont stockées.

Pour que tout ce petit monde fonctionne en harmonie sur n'importe quelle machine (la tienne, la mienne, celle d'un serveur...), on utilise **Docker**.

### Pourquoi Docker ? (Et pourquoi c'est génial pour toi)

Imagine que tu doives installer manuellement Angular, Node.js, et MongoDB sur ta machine. Tu pourrais rencontrer des problèmes de version, des conflits avec d'autres projets... Bref, un vrai casse-tête et crois moi, je sais de quoi je parle.

Docker nous sauve de tout ça. Il nous permet d'empaqueter chaque brique (frontend, backend, base de données) dans une "boîte" isolée qu'on appelle un **conteneur**. Ces conteneurs ont tout ce dont ils ont besoin pour fonctionner et ne se mélangent pas avec le reste de ton système.

**En résumé : grâce à Docker, l'installation se résume à une seule commande, et ça marche partout, tout le temps.**

## Comment lancer le projet : Le Guide du Débutant

Je me suis fais vraiment chier pour créé un script magique, [`install.sh`](install.sh), qui fait tout le travail pour toi. Il va te poser quelques questions, et hop, tout sera prêt.

**Les seules choses dont tu as besoin sur ta machine sont :**
1.  **Docker**
2.  **Docker Compose** (qui est maintenant inclus avec Docker Desktop ou s'installe comme un plugin sur Linux).

C'est tout ! Pas besoin d'installer Node, Angular ou MongoDB.

### Étape 1 : Lancer l'Installation

Ouvre un terminal (ou une invite de commande) à la racine de ton projet.

La première fois, il faut donner au script la permission de s'exécuter. C'est une sécurité.
```bash
chmod +x install.sh
```

Maintenant, lance le script :
```bash
./install.sh
```

### Étape 2 : Dialoguer avec le Script

Le script est ton assistant personnel. Il va :

1.  **Vérifier que tout est prêt** : Il s'assure que Docker fonctionne bien.
2.  **Te poser des questions** :
    *   Quel nom veux-tu donner à ton projet ?
    *   Quels ports veux-tu utiliser pour le site, l'API et la base de données ?
    *   Quels noms veux-tu donner à tes conteneurs Docker ?

**Pourquoi ces questions ?** Pour la flexibilité ! Si un port ou un nom de conteneur est déjà utilisé sur ta machine, pas de panique ! Le script le détectera et te proposera une alternative. TU AS LE CONTRÔLE TOTAL (du moins on verra mouhahahaha).

### Étape 3 : La Magie Opère

Une fois que tu as répondu, le script va :
1.  Créer un fichier `.env` qui est ta configuration personnelle (un peu comme une carte d'identité pour ton projet).
2.  Donner les instructions à Docker pour construire et lancer les conteneurs.
3.  **Vérifier que tout a bien démarré**. Si un conteneur a un problème, le script te le dira et te montrera même les logs pour t'aider à comprendre pourquoi. Fini les devinettes !

### Étape 4 : C'est Prêt !

Si tout s'est bien passé, le script t'affichera les adresses pour accéder à ton application :
*   **Le site web (Frontend)** : `http://localhost:PORT_FRONTEND`
*   **L'API (Backend)** : `http://localhost:PORT_BACKEND`

Et voilà ! Ton environnement de développement est prêt, fonctionnel et isolé.

### Étape 5 : Lancer l'application (parce que c'est pas fini, évidemment)

Bon, l'environnement est prêt, c'est super. Mais l'application, elle, ne s'est pas encore lancée toute seule comme par magie.

Maintenant, et c'est une étape cruciale que beaucoup semblent oublier, il faut **aller dans le dossier du projet** (oui, celui où tu as lancé le script et choisi le nom de ton truc) et taper la commande suivante :

```bash
npm start
```

Incroyable, non ? Cette commande va enfin démarrer le serveur de développement Angular. Sans ça, tu risques de regarder une page blanche pendant un bon moment en te demandant ce qui ne va pas. Ne sois pas cette personne.
## La vie après l'installation : Commandes utiles

Ton environnement tourne en arrière-plan. Voici comment interagir avec lui :

*   **Pour espionner ce que fabriquent tes conteneurs (les logs)** :
    ```bash
    docker compose logs -f
    ```
    Ça va cracher tout ce qu'il se passe en temps réel. Parfait pour jouer les détectives quand un truc foire. *(Appuie sur `Ctrl+C` pour arrêter de les harceler)*

*   **Pour leur dire d'aller se coucher (arrêter les conteneurs)** :
    ```bash
    docker compose down
    ```
    Ça arrête tout proprement. Les conteneurs dorment, mais ils n'ont rien oublié. Si tu les relances, ils reprennent où ils en étaient (sauf la base de données qui perdra ses données si elle n'est pas dans un volume persistant, mais t'inquiète, c'est le cas ici).

*   **Pour tout mettre à la poubelle (arrêter ET supprimer les données)** :
    ```bash
    docker compose down --volumes
    ```
    Là, c'est plus sérieux. Non seulement tu les arrêtes, mais tu balances aussi leur mémoire (le volume de la base de données) aux ordures. C'est l'option "je veux repartir de zéro, comme si rien de tout ça n'était jamais arrivé".

*   **L'OPTION NUCLÉAIRE : Quand tout est foutu (`docker-cleanup.sh`)**
    Parfois, t'as tellement merdé que même `docker compose down` ne suffit plus. T'as des images qui traînent, des réseaux fantômes... Bref, c'est le chaos.
    Pas de panique, j'ai prévu un bouton rouge pour toi (va pas faire péter l'Ukraine).

    D'abord, on le rend exécutable (juste la première fois, pas la peine de le faire à chaque fois, t'es pas un robot, tout dépend de qui on parle évidement) :

    ```bash
    chmod +x docker-cleanup.sh
    ```
    Et maintenant, le grand nettoyage :
    ```bash
    ./docker-cleanup.sh
    ```
    Ce script est l'agent d'entretien ultime. Il va **arrêter et supprimer tous les conteneurs**, **nettoyer les réseaux** et **supprimer les images Docker** liées à ce projet. Après son passage, ton système est aussi propre qu'un slip neuf. C'est radical, mais putain, c'est efficace.

## Comment ça marche sous le capot ? (Pour les curieux)

*   [`install.sh`](install.sh) : Le chef d'orchestre. C'est ton assistant personnel, celui qui te pose des questions et qui s'assure que ton environnement est taillé sur mesure pour toi. C'est lui qui crie les ordres.
*   [`setup.sh`](setup.sh) : L'installateur. Une fois que le conteneur principal est lancé, ce petit gars s'exécute **une seule fois** pour installer Angular et créer la structure de base de ton projet. Il prépare le terrain.
*   [`docker-cleanup.sh`](docker-cleanup.sh) : Le nettoyeur. Quand tu veux faire table rase et tout effacer sans laisser de traces, c'est ton homme. Radical et sans pitié.
*   [`docker-compose.yml`](docker-compose.yml) : Le plan de l'architecte. Ce fichier, c'est la carte. Il dit à Docker : "Construis-moi un service web comme ça, une base de données comme ci, et fais-les communiquer entre eux." Il utilise les variables de ton fichier `.env` pour ne pas tout écrire en dur comme un débutant.
*   [`Dockerfile`](Dockerfile) : La recette de cuisine. Il explique, étape par étape, comment construire l'image de ton application : "Prends une base Node.js, ajoute ces paquets, copie le code source, et lance cette commande au démarrage."
*   [`.env.example`](.env.example) : Le pense-bête. C'est le modèle pour ton fichier de configuration personnel. Il te montre toutes les variables que tu DOIS définir.
*   `.env` : Ta configuration secrète. Ce fichier est généré par `install.sh` avec TES réponses. Il contient les ports, les noms, etc. Il est ignoré par Git pour que tu ne partages pas tes petits secrets avec tout le monde. C'est TON fichier, pas touche.

---

J'espère que ce guide t'a été utile. Si tu as la moindre question, n'hésite pas. L'objectif est que tout le monde puisse se lancer sur ce projet sans friction.

Bon développement !