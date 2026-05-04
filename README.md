# 🏭 PLCIOsim Offline

> Simulateur PLC (Programmable Logic Controller) hors-ligne, inspiré de plciosim.com  
> Stack : PHP (Laravel/Laragon) + Vanilla JS + Mistral AI + SQLite

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Stack technique](#stack-technique)
3. [Architecture du projet](#architecture-du-projet)
4. [Installation](#installation)
5. [Modules fonctionnels](#modules-fonctionnels)
6. [Moteur de simulation PLC](#moteur-de-simulation-plc)
7. [API Mistral AI](#api-mistral-ai)
8. [Base de données](#base-de-données)
9. [Guide développeur](#guide-développeur)
10. [Roadmap](#roadmap)

---

## Vue d'ensemble

PLCIOsim Offline est une application web locale qui reproduit intégralement les fonctionnalités de plciosim.com, avec en plus l'assistance de l'IA Mistral pour :
- Générer du code Ladder Logic depuis une description en langage naturel
- Expliquer les erreurs de logique
- Suggérer des optimisations de programme
- Répondre aux questions sur la programmation PLC

### Fonctionnalités principales

| Fonctionnalité | Description |
|---|---|
| 🪜 Éditeur Ladder | Éditeur visuel drag & drop complet |
| 📝 Structured Text | Mode alternatif de programmation |
| 🔌 Panneau I/O | Devices interactifs (boutons, lampes, moteurs, capteurs...) |
| 🎬 Scènes animées | Air Compressor, Bottle Fill, Car Wash, Conveyor... |
| 💾 Projets | Sauvegarde locale (SQLite) |
| 📚 Examples | Bibliothèque d'exemples intégrés |
| 👥 Community | Partage local via export/import JSON |
| 🧩 Problems | Challenges avec validation automatique |
| 🤖 Assistant IA | Mistral AI intégré pour aide à la programmation |
| ⚙️ Settings | Thème Light/Dark + choix de layout |

---

## Stack technique

```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (Browser)                    │
│  HTML5 + CSS3 + Vanilla JS (ES6 Modules)                │
│  Canvas API (Ladder Editor)                             │
│  SVG (I/O Devices + Scènes animées)                     │
│  Web Workers (Moteur de simulation PLC)                  │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP / fetch API
┌──────────────────────▼──────────────────────────────────┐
│                   BACKEND (Laragon)                      │
│  PHP 8.2+ (pas de framework — PHP pur pour légèreté)    │
│  Routing manuel via index.php + .htaccess               │
│  SQLite 3 (via PDO) — pas de serveur DB requis          │
│  API REST JSON                                          │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTPS API
┌──────────────────────▼──────────────────────────────────┐
│                  MISTRAL AI (Cloud)                      │
│  API Key personnelle                                    │
│  Modèle : mistral-large-latest (ou mistral-small)       │
│  Endpoints : /chat, /generate-ladder, /explain          │
└─────────────────────────────────────────────────────────┘
```

### Pourquoi ces choix ?

| Choix | Raison |
|---|---|
| **PHP pur** (pas Laravel) | Laragon est déjà configuré, zéro dépendance, démarrage immédiat |
| **SQLite** | Pas de serveur MySQL requis, fichier portable, parfait pour offline |
| **Vanilla JS** | Pas de build tool (Webpack/Vite), fonctionne directement dans le browser |
| **Canvas + SVG** | Canvas pour l'éditeur Ladder (performance), SVG pour les devices I/O (interactivité) |
| **Web Workers** | Le moteur de scan PLC tourne dans un thread séparé sans bloquer l'UI |
| **Mistral AI** | API disponible, excellente pour le code et l'explication technique |

---

## Architecture du projet

```
plciosim-offline/
│
├── 📄 README.md                    ← Ce fichier
├── 📄 .htaccess                    ← Routing PHP + sécurité
├── 📄 index.php                    ← Point d'entrée PHP (router)
├── 📄 config.php                   ← Configuration (clé API, DB path...)
│
├── 📁 api/                         ← Endpoints REST
│   ├── projects.php               ← CRUD projets
│   ├── examples.php               ← Lecture exemples
│   ├── problems.php               ← Challenges + validation
│   ├── community.php              ← Projets partagés
│   ├── ai.php                     ← Proxy Mistral AI
│   └── auth.php                   ← Auth locale (optionnel)
│
├── 📁 database/
│   ├── plciosim.sqlite            ← Base de données SQLite
│   ├── schema.sql                 ← Schéma de création des tables
│   └── seeds/
│       ├── examples.json          ← Données exemples intégrés
│       └── problems.json          ← Données challenges
│
├── 📁 public/                      ← Fichiers servis au browser
│   │
│   ├── 📁 css/
│   │   ├── main.css               ← Variables CSS + reset
│   │   ├── layout.css             ← Grilles et layouts (3 options)
│   │   ├── ladder.css             ← Styles éditeur Ladder
│   │   ├── io-panel.css           ← Styles panneau I/O
│   │   ├── scene.css              ← Styles scènes animées
│   │   ├── modals.css             ← Fenêtres modales
│   │   └── themes/
│   │       ├── light.css          ← Thème clair
│   │       └── dark.css           ← Thème sombre
│   │
│   ├── 📁 js/
│   │   │
│   │   ├── 📁 core/               ← MOTEUR PLC (logique métier)
│   │   │   ├── plc-engine.js      ← Moteur de scan PLC principal
│   │   │   ├── plc-worker.js      ← Web Worker du moteur
│   │   │   ├── instruction-set.js ← Toutes les instructions (XIC,XIO,OTE,TON...)
│   │   │   ├── tag-manager.js     ← Gestionnaire de tags/variables
│   │   │   └── program-validator.js ← Validation syntaxe
│   │   │
│   │   ├── 📁 ui/                 ← INTERFACE UTILISATEUR
│   │   │   ├── app.js             ← Bootstrap de l'application
│   │   │   ├── router.js          ← SPA Router côté client
│   │   │   ├── ladder-editor.js   ← Éditeur Ladder (Canvas)
│   │   │   ├── structured-text-editor.js ← Éditeur ST
│   │   │   ├── io-panel.js        ← Panneau I/O interactif
│   │   │   ├── tag-panel.js       ← Panneau Tags
│   │   │   ├── toolbar.js         ← Barre d'outils + instructions
│   │   │   ├── ai-assistant.js    ← Chat IA Mistral
│   │   │   └── modals.js          ← Gestion des modales
│   │   │
│   │   ├── 📁 scenes/             ← SCÈNES ANIMÉES (SVG)
│   │   │   ├── scene-manager.js   ← Gestionnaire de scènes
│   │   │   ├── air-compressor.js  ← Scène Air Compressor
│   │   │   ├── bottle-fill.js     ← Scène Bottle Fill
│   │   │   ├── car-wash.js        ← Scène Car Wash
│   │   │   ├── conveyor.js        ← Scène Conveyor Belt
│   │   │   ├── garage-door.js     ← Scène Garage Door
│   │   │   ├── water-tank.js      ← Scène Water Tank
│   │   │   ├── traffic-light.js   ← Scène Traffic Light
│   │   │   └── base-scene.js      ← Classe abstraite Scene
│   │   │
│   │   ├── 📁 io-devices/         ← DEVICES I/O INTERACTIFS (SVG)
│   │   │   ├── device-registry.js ← Registre de tous les devices
│   │   │   ├── pushbutton-no.js   ← Bouton poussoir NO
│   │   │   ├── pushbutton-nc.js   ← Bouton poussoir NC
│   │   │   ├── selector-switch.js ← Sélecteur rotatif
│   │   │   ├── limit-switch.js    ← Fin de course
│   │   │   ├── lamp.js            ← Lampe indicatrice
│   │   │   ├── motor.js           ← Moteur (contactor)
│   │   │   ├── solenoid.js        ← Vanne solénoïde
│   │   │   └── sensor.js          ← Capteur générique
│   │   │
│   │   └── 📁 utils/              ← UTILITAIRES
│   │       ├── api-client.js      ← Client HTTP vers backend PHP
│   │       ├── storage.js         ← LocalStorage + IndexedDB helpers
│   │       ├── event-bus.js       ← Bus d'événements global
│   │       └── serializer.js      ← Sérialisation JSON des projets
│   │
│   └── 📁 assets/
│       ├── 📁 icons/              ← Icônes SVG des instructions et devices
│       ├── 📁 scenes/             ← Assets SVG des scènes
│       └── 📁 fonts/              ← Polices locales (offline)
│
├── 📁 views/                       ← Templates HTML PHP
│   ├── layout.php                 ← Template principal
│   ├── editor.php                 ← Page éditeur
│   ├── projects.php               ← Page projets
│   ├── examples.php               ← Page exemples
│   ├── community.php              ← Page community
│   ├── problems.php               ← Page problems
│   ├── settings.php               ← Page settings
│   ├── signin.php                 ← Page connexion
│   └── help.php                   ← Page aide
│
├── 📁 src/                         ← Classes PHP
│   ├── Router.php                 ← Router HTTP
│   ├── Database.php               ← Singleton PDO/SQLite
│   ├── MistralClient.php          ← Client API Mistral
│   ├── ProjectRepository.php      ← CRUD projets
│   ├── ProblemValidator.php       ← Validation challenges côté serveur
│   └── Auth.php                   ← Authentification locale
│
├── 📁 docs/                        ← Documentation technique
│   ├── INSTRUCTION_SET.md         ← Documentation instructions PLC
│   ├── SCENE_API.md               ← API des scènes animées
│   ├── IO_DEVICES_API.md          ← API des devices I/O
│   ├── AI_PROMPTS.md              ← Prompts système Mistral
│   └── ARCHITECTURE.md            ← Diagrammes d'architecture
│
└── 📁 tests/
    ├── engine/                    ← Tests moteur PLC
    └── api/                       ← Tests endpoints PHP
```

---

## Installation

### Prérequis

- [Laragon](https://laragon.org/) installé et démarré
- PHP 8.2+ (inclus dans Laragon)
- Extension SQLite activée dans PHP (activée par défaut dans Laragon)
- Clé API Mistral : [console.mistral.ai](https://console.mistral.ai/)

### Étapes

```bash
# 1. Cloner/copier le projet dans le dossier www de Laragon
# Par défaut : C:\laragon\www\plciosim-offline\
# ou          : C:\Users\<user>\laragon\www\plciosim-offline\

# 2. Copier le fichier de config
cp config.example.php config.php

# 3. Éditer config.php — renseigner la clé API Mistral
# MISTRAL_API_KEY=votre_clé_ici

# 4. Initialiser la base de données
php database/init.php

# 5. Accéder à l'application
# http://plciosim.test   (si virtual host Laragon configuré)
# http://localhost/plciosim-offline/
```

### Configuration Laragon (Virtual Host recommandé)

Laragon crée automatiquement un virtual host si le dossier est dans `www/`.  
L'URL sera : **http://plciosim.test**

---

## Modules fonctionnels

### 1. Éditeur Ladder (Canvas)

L'éditeur Ladder est rendu sur un élément `<canvas>` HTML5.

**Composants visuels :**
- Rails gauche et droite (lignes d'alimentation)
- Rungs numérotés
- Instructions placées sur les rungs (contacts, bobines, blocs)
- Fils de connexion (power flow)
- Indicateurs de state (bleu = energized, gris = de-energized)

**Interactions :**
- Clic sur instruction toolbar → sélection
- Clic sur rung → insertion de l'instruction sélectionnée
- Clic droit → menu contextuel (supprimer, propriétés)
- Double-clic sur instruction → édition du tag associé
- Drag → déplacement d'instructions

### 2. Instructions supportées

#### Catégorie Bit (Contacts & Bobines)
| Instruction | Nom | Description |
|---|---|---|
| XIC | Examine If Closed | Contact NO — vrai si le bit est 1 |
| XIO | Examine If Open | Contact NC — vrai si le bit est 0 |
| OTE | Output Energize | Bobine — met le bit à 1 si rung vrai |
| OTL | Output Latch | Bobine verrouillée — met le bit à 1 |
| OTU | Output Unlatch | Bobine déverrouillée — met le bit à 0 |
| OSR | One Shot Rising | Impulsion sur front montant |
| OSF | One Shot Falling | Impulsion sur front descendant |

#### Catégorie Timer
| Instruction | Nom | Description |
|---|---|---|
| TON | Timer On-Delay | Délai à l'activation |
| TOF | Timer Off-Delay | Délai à la désactivation |
| RTO | Retentive Timer On | Timer retentif |
| RES | Reset | Remise à zéro timer/counter |

#### Catégorie Counter
| Instruction | Nom | Description |
|---|---|---|
| CTU | Count Up | Comptage croissant |
| CTD | Count Down | Comptage décroissant |
| RES | Reset | Remise à zéro |

#### Catégorie Math
| Instruction | Nom | Description |
|---|---|---|
| ADD | Add | Addition |
| SUB | Subtract | Soustraction |
| MUL | Multiply | Multiplication |
| DIV | Divide | Division |
| MOV | Move | Copie de valeur |

#### Catégorie Compare
| Instruction | Nom | Description |
|---|---|---|
| EQU | Equal | Égal |
| NEQ | Not Equal | Différent |
| LES | Less Than | Inférieur |
| LEQ | Less or Equal | Inférieur ou égal |
| GRT | Greater Than | Supérieur |
| GEQ | Greater or Equal | Supérieur ou égal |

### 3. Devices I/O

Chaque device est un SVG interactif qui :
- Expose un état booléen (ou numérique pour analogique)
- Répond aux interactions utilisateur (clic, glisser)
- Est lié à un tag dans le programme
- Réagit visuellement selon l'état du programme

| Device | Type | Interaction |
|---|---|---|
| Pushbutton NO | Input | Clic maintenu = HIGH |
| Pushbutton NC | Input | Clic maintenu = LOW |
| Selector Switch | Input | Clic = toggle position |
| Limit Switch | Input | Activé par scène |
| Lamp | Output | Allumée si tag = 1 |
| Motor Contactor | Output | Tourne si tag = 1 |
| Solenoid Valve | Output | Ouverte si tag = 1 |
| Analog Slider | Input | Glisser = valeur 0-100 |

### 4. Scènes animées

Chaque scène est un SVG animé qui :
- Visualise un processus industriel réel
- Interagit avec les devices I/O
- Réagit en temps réel au programme PLC en cours d'exécution

| Scène | Description | Devices impliqués |
|---|---|---|
| Air Compressor | Compresseur qui se remplit | Motor, Pressure switch, Lamp |
| Bottle Fill | Remplissage de bouteilles | Conveyor motor, Valve, Level sensor |
| Car Wash | Lavage automatique | Multiple motors, Sensors, Lamps |
| Conveyor | Tapis roulant | Motor, Limit switches, Objects |
| Garage Door | Porte de garage | FWD/REV motor, Limit UP/DOWN |
| Water Tank | Réservoir d'eau | Fill valve, Drain valve, Level switches |
| Traffic Light | Feux de circulation | 3 Lamps (R/Y/G), Timers |

### 5. Système Problems (Challenges)

Chaque challenge définit :
- Un **énoncé** décrivant le comportement attendu
- Une **scène** de visualisation
- Les **devices I/O** disponibles (pré-configurés)
- Des **tests automatiques** (vecteurs d'entrée → sorties attendues)
- Un niveau de **difficulté** : EASY / MEDIUM / HARD

La validation se fait côté JS (moteur PLC) + vérification PHP.

### 6. Assistant IA (Mistral)

Le panneau IA (accessible via bouton flottant) permet :

| Action | Description |
|---|---|
| 💬 Chat libre | Poser des questions sur le PLC/Ladder |
| 🪜 Générer Ladder | "Crée un programme pour contrôler une pompe" → code généré |
| 🔍 Expliquer | Sélectionner des rungs → "Explique ce code" |
| 🐛 Debugger | "Pourquoi ma lampe ne s'allume pas ?" |
| 📖 Apprendre | Cours et explications sur les instructions |

---

## Moteur de simulation PLC

### Principe du Scan Cycle

Le moteur simule le comportement d'un vrai PLC :

```
┌─────────────────────────────────────┐
│           SCAN CYCLE (50ms)          │
│                                     │
│  1. READ INPUTS                     │
│     Lire tous les états I/O         │
│     → mettre à jour table I/O       │
│                                     │
│  2. EXECUTE PROGRAM                 │
│     Parcourir tous les rungs        │
│     → évaluer chaque instruction    │
│     → mettre à jour table outputs  │
│                                     │
│  3. WRITE OUTPUTS                   │
│     Écrire les outputs calculés     │
│     → mettre à jour devices I/O     │
│     → mettre à jour scènes          │
│                                     │
│  4. HOUSEKEEPING                    │
│     Timers, counters, diagnostics   │
└─────────────────────────────────────┘
         ↑                  |
         └──────────────────┘
              repeat
```

### Implémentation Web Worker

```javascript
// plc-worker.js — tourne dans un thread séparé
self.onmessage = function(e) {
  const { type, payload } = e.data;
  
  switch(type) {
    case 'START':
      startScanCycle(payload.program, payload.ioState);
      break;
    case 'STOP':
      stopScanCycle();
      break;
    case 'UPDATE_IO':
      updateIOState(payload);
      break;
  }
};

function scanCycle() {
  // 1. Read inputs (reçus via message)
  // 2. Execute ladder program
  const result = executeLadder(currentProgram, ioTable);
  // 3. Send outputs back to main thread
  self.postMessage({ type: 'SCAN_RESULT', payload: result });
}
```

---

## API Mistral AI

### Proxy PHP (sécurité — la clé n'est jamais exposée au browser)

```
Browser → POST /api/ai → PHP (MistralClient.php) → Mistral API
```

### Endpoints IA

```http
POST /api/ai/chat
Content-Type: application/json

{
  "message": "Comment fonctionne le TON timer ?",
  "context": "plc_education",
  "history": [...]
}
```

```http
POST /api/ai/generate-ladder
Content-Type: application/json

{
  "description": "Contrôler un convoyeur avec start/stop et seal-in",
  "available_io": ["PB1_NO", "PB2_NC", "MOTOR1"]
}
```

```http
POST /api/ai/explain
Content-Type: application/json

{
  "program": { ...ladder JSON... },
  "selection": [0, 1, 2]
}
```

### System Prompt Mistral

```
Tu es un expert en programmation PLC (Programmable Logic Controller),
spécialisé dans le langage Ladder Logic (IEC 61131-3).
Tu assistes des apprenants dans plcIOsim, un simulateur PLC éducatif.

Contexte du simulateur :
- Instructions disponibles : XIC, XIO, OTE, OTL, OTU, OSR, TON, TOF, CTU, CTD, ADD, SUB, MUL, DIV, MOV, EQU, NEQ, LES, LEQ, GRT, GEQ
- Tags : BOOL, INT, DINT, REAL
- Mode de simulation : Scan cycle 50ms

Quand tu génères du Ladder Logic, utilise ce format JSON :
{
  "rungs": [
    {
      "id": 0,
      "instructions": [
        { "type": "XIC", "tag": "PB1", "position": 0 },
        { "type": "OTE", "tag": "LAMP1", "position": 1 }
      ]
    }
  ]
}

Sois précis, pédagogique, et donne toujours des exemples concrets.
```

---

## Base de données

### Schéma SQLite

```sql
-- Utilisateurs (auth locale optionnelle)
CREATE TABLE users (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    username    TEXT UNIQUE NOT NULL,
    email       TEXT UNIQUE,
    password    TEXT NOT NULL,          -- bcrypt
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Projets
CREATE TABLE projects (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER REFERENCES users(id),
    title       TEXT NOT NULL,
    description TEXT,
    program     TEXT NOT NULL,          -- JSON (rungs, tags, io config)
    scene       TEXT,                   -- Nom de la scène associée
    is_shared   INTEGER DEFAULT 0,      -- 0=privé, 1=communauté
    upvotes     INTEGER DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Exemples (seeds — ne pas modifier)
CREATE TABLE examples (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    order_num       INTEGER,
    title           TEXT NOT NULL,
    description     TEXT NOT NULL,
    program         TEXT NOT NULL,     -- JSON
    scene           TEXT,
    io_devices      TEXT,              -- JSON array
    instructions_used TEXT            -- JSON array
);

-- Challenges / Problems
CREATE TABLE problems (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    order_num   INTEGER,
    title       TEXT NOT NULL,
    description TEXT NOT NULL,
    difficulty  TEXT CHECK(difficulty IN ('EASY','MEDIUM','HARD')),
    scene       TEXT,
    io_config   TEXT NOT NULL,         -- JSON (devices disponibles)
    test_vectors TEXT NOT NULL,        -- JSON (inputs → outputs attendus)
    program_template TEXT             -- JSON (template optionnel)
);

-- Completions (challenges résolus)
CREATE TABLE completions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER REFERENCES users(id),
    problem_id  INTEGER REFERENCES problems(id),
    program     TEXT,                  -- Solution soumise
    completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, problem_id)
);

-- Historique IA
CREATE TABLE ai_history (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER REFERENCES users(id),
    session_id  TEXT,
    role        TEXT CHECK(role IN ('user','assistant')),
    content     TEXT NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Settings utilisateur
CREATE TABLE user_settings (
    user_id     INTEGER PRIMARY KEY REFERENCES users(id),
    theme       TEXT DEFAULT 'light',
    layout      INTEGER DEFAULT 1,    -- 1, 2 ou 3
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## Guide développeur

### Ajouter une nouvelle instruction

1. Déclarer dans `public/js/core/instruction-set.js` :
```javascript
export class TON_Instruction {
  constructor(tag, preset) {
    this.tag = tag;
    this.preset = preset; // en ms
  }
  
  execute(tagTable, timers) {
    const timer = timers.get(this.tag) || { acc: 0, en: false, dn: false, tt: false };
    // logique TON...
    return { ...timer };
  }
}
```

2. Ajouter l'icône SVG dans `public/assets/icons/`

3. Enregistrer dans la toolbar `public/js/ui/toolbar.js`

### Ajouter une nouvelle scène

1. Créer `public/js/scenes/ma-scene.js` :
```javascript
import { BaseScene } from './base-scene.js';

export class MaScene extends BaseScene {
  constructor(container) {
    super(container);
    this.svg = this.buildSVG();
  }
  
  buildSVG() { /* Construire le SVG de la scène */ }
  
  // Appelé à chaque scan cycle
  update(ioState) {
    // Animer la scène selon l'état des I/O
    if (ioState['MOTOR1']) {
      this.animateMotor();
    }
  }
  
  // Définir les devices I/O de cette scène
  getIODevices() {
    return [
      { tag: 'MOTOR1', type: 'motor', label: 'Motor' },
      { tag: 'LS_UP', type: 'limit-switch', label: 'Limit UP' }
    ];
  }
}
```

2. Enregistrer dans `public/js/scenes/scene-manager.js`

3. Ajouter le seed dans `database/seeds/scenes.json`

### Ajouter un challenge

Éditer `database/seeds/problems.json` :
```json
{
  "order_num": 6,
  "title": "Traffic Light",
  "description": "Design a program to control a 3-phase traffic light...",
  "difficulty": "MEDIUM",
  "scene": "traffic-light",
  "io_config": {
    "inputs": [],
    "outputs": [
      { "tag": "RED", "type": "lamp", "color": "red" },
      { "tag": "YELLOW", "type": "lamp", "color": "yellow" },
      { "tag": "GREEN", "type": "lamp", "color": "green" }
    ]
  },
  "test_vectors": [
    { "time_ms": 0, "expected": { "RED": 1, "YELLOW": 0, "GREEN": 0 } },
    { "time_ms": 5000, "expected": { "RED": 0, "YELLOW": 0, "GREEN": 1 } },
    { "time_ms": 10000, "expected": { "RED": 0, "YELLOW": 1, "GREEN": 0 } }
  ]
}
```

---

## Roadmap

### Phase 1 — MVP (Semaines 1-4)
- [x] Structure du projet
- [ ] Router PHP + templates de base
- [ ] Éditeur Ladder basique (XIC, XIO, OTE)
- [ ] Panneau I/O (Pushbutton + Lamp)
- [ ] Moteur de simulation (scan cycle basique)
- [ ] Sauvegarde locale SQLite

### Phase 2 — Core Features (Semaines 5-8)
- [ ] Instructions complètes (Timer, Counter, Math, Compare)
- [ ] Structured Text editor
- [ ] Toutes les scènes animées
- [ ] Tous les devices I/O
- [ ] Système Examples + Problems

### Phase 3 — AI + Polish (Semaines 9-12)
- [ ] Intégration Mistral AI
- [ ] Community (export/import JSON)
- [ ] Settings (thème + layout)
- [ ] Tests automatiques challenges
- [ ] Documentation in-app

### Phase 4 — Extras (Semaines 13+)
- [ ] Export programme (CSV, JSON, ST)
- [ ] Mode impression (PDF du programme)
- [ ] Historique undo/redo illimité
- [ ] Raccourcis clavier complets
- [ ] Mode plein écran par panneau

---

## Licence

Projet personnel / éducatif. Inspiré de plciosim.com.  
Ne pas distribuer commercialement sans autorisation.

---

*Généré le 2026-05-04 — PLCIOsim Offline v0.1.0*
