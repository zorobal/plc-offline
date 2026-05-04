# PLCIOsim Offline - Guide d'Installation

## Prérequis
- **Laragon** (ou tout serveur web avec PHP 8.0+ et SQLite)
- Navigateur web moderne (Chrome, Firefox, Edge)

## Installation avec Laragon

### Étape 1 : Cloner le projet
1. Ouvre Laragon
2. Clique sur "Quick App" → "New"
3. Nomme ton projet `plciosim-offline`
4. Copie tous les fichiers du dépôt dans `C:\laragon\www\plciosim-offline\`

### Étape 2 : Configuration
Le fichier `config.php` est déjà configuré avec ta clé API Mistral.

Vérifie que ces constantes sont correctes :
```php
define('MISTRAL_API_KEY', 'IOxxOSCGW86qkK8VbaeKefRkpNkd0cOg');
define('APP_URL', 'http://plciosim-offline.test'); // ou http://localhost/plciosim-offline
```

### Étape 3 : Démarrer le serveur
1. Dans Laragon, clique sur "Start All"
2. Le domaine `http://plciosim-offline.test` devrait être accessible automatiquement
3. Sinon, utilise `http://localhost/plciosim-offline`

### Étape 4 : Première utilisation
1. Ouvre ton navigateur et va sur `http://plciosim-offline.test`
2. La base de données SQLite sera créée automatiquement
3. Les exemples et challenges seront initialisés

## Structure du projet

```
plciosim-offline/
├── api/              # Endpoints REST API
│   ├── ai.php        # Intégration Mistral AI
│   ├── auth.php      # Authentification
│   ├── projects.php  # Gestion des projets
│   └── ...
├── src/              # Classes PHP
│   ├── Database.php  # Gestion SQLite
│   ├── Auth.php      # Authentification
│   ├── MistralClient.php # Client API Mistral
│   └── Router.php    # Routeur HTTP
├── views/            # Templates HTML
│   ├── editor.php    # Éditeur Ladder principal
│   ├── projects.php  # Liste des projets
│   └── ...
├── public/           # Assets statiques
│   ├── css/style.css
│   └── js/app.js
├── database/         # Base de données SQLite
│   └── schema.sql
├── config.php        # Configuration
├── index.php         # Point d'entrée unique
└── plc-engine.js     # Moteur de simulation PLC
```

## Fonctionnalités

### ✅ Implémentées
- Éditeur Ladder avec tags et rungs
- Simulation PLC (scan cycle)
- Intégration Mistral AI pour :
  - Générer des programmes depuis une description
  - Expliquer un programme existant
  - Debugger un programme
- Sauvegarde des projets en base SQLite
- Exemples et challenges intégrés
- Historique des conversations IA

### 🚧 En développement
- Validation automatique des solutions
- Scènes 3D/2D pour la visualisation
- Partage communautaire des projets

## Test de l'API Mistral

Pour tester que l'intégration Mistral fonctionne :

1. Ouvre l'éditeur (`/`)
2. Clique sur "🤖 Générer avec IA"
3. Décris un comportement simple : 
   *"Un bouton poussoir qui allume une lampe et la maintient allumée"*
4. L'IA devrait générer un programme ladder avec un latch

## Dépannage

### Erreur "Database not found"
La base de données se crée automatiquement. Vérifie que le dossier `database/` a les permissions en écriture.

### Erreur API Mistral
- Vérifie ta clé API dans `config.php`
- Assure-toi d'avoir une connexion internet
- Consulte la console navigateur (F12) pour les détails

### Routes non trouvées (404)
Sous Apache, assure-toi que le `.htaccess` redirige toutes les requêtes vers `index.php`.

## Support

Pour toute question, consulte le README.md ou ouvre une issue.
