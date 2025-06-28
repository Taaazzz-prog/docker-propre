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

## La vie après l'installation : Commandes utiles

Ton environnement tourne en arrière-plan. Voici comment interagir avec lui :

*   **Pour voir ce qu'il se passe (les logs)** :
    ```bash
    docker compose logs -f
    ```
    *(Appuie sur `Ctrl+C` pour quitter)*

*   **Pour tout arrêter proprement** :
    ```bash
    docker compose down
    ```

*   **Pour tout arrêter ET supprimer les données de la base de données (pour repartir de zéro)** :
    ```bash
    docker compose down --volumes
    ```

## Comment ça marche sous le capot ? (Pour les curieux)

*   [`docker-compose.yml`](docker-compose.yml) : C'est le plan de construction. Il décrit les services (app, mongo), comment ils sont connectés, et quels ports ils utilisent, en se basant sur ton fichier `.env`.
*   [`Dockerfile`](Dockerfile) : C'est la recette de cuisine pour notre conteneur principal. Il explique comment prendre une version de Node.js, copier notre code, et installer les dépendances.
*   [`setup.sh`](setup.sh) : C'est un petit script qui s'exécute **une seule fois** à l'intérieur du conteneur. C'est lui qui installe Angular CLI et crée ton projet avec le nom que tu as choisi.

---

J'espère que ce guide t'a été utile. Si tu as la moindre question, n'hésite pas. L'objectif est que tout le monde puisse se lancer sur ce projet sans friction.

Bon développement !