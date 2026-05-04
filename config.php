<?php
/**
 * PLCIOsim Offline — Configuration
 * Copier ce fichier en config.php et renseigner les valeurs
 */

// ─────────────────────────────────────────────
// MISTRAL AI
// ─────────────────────────────────────────────
define('MISTRAL_API_KEY', 'votre_clé_mistral_ici');
define('MISTRAL_MODEL',   'mistral-large-latest');  // ou 'mistral-small-latest' (moins cher)
define('MISTRAL_API_URL', 'https://api.mistral.ai/v1/chat/completions');
define('MISTRAL_MAX_TOKENS', 2048);
define('MISTRAL_TEMPERATURE', 0.3);  // Bas = plus précis pour du code

// ─────────────────────────────────────────────
// BASE DE DONNÉES
// ─────────────────────────────────────────────
define('DB_PATH', __DIR__ . '/database/plciosim.sqlite');
define('DB_SCHEMA', __DIR__ . '/database/schema.sql');

// ─────────────────────────────────────────────
// APPLICATION
// ─────────────────────────────────────────────
define('APP_NAME',    'PLCIOsim Offline');
define('APP_VERSION', '0.1.0');
define('APP_URL',     'http://plciosim.test'); // ou http://localhost/plciosim-offline
define('APP_ENV',     'development');          // 'development' ou 'production'
define('APP_DEBUG',   true);

// ─────────────────────────────────────────────
// SESSION & SÉCURITÉ
// ─────────────────────────────────────────────
define('SESSION_NAME',     'plciosim_session');
define('SESSION_LIFETIME', 86400 * 7); // 7 jours
define('BCRYPT_ROUNDS',    12);
define('CSRF_TOKEN_NAME',  '_csrf');

// ─────────────────────────────────────────────
// SIMULATION PLC
// ─────────────────────────────────────────────
define('SCAN_CYCLE_MS',    50);   // Durée d'un scan cycle (ms)
define('MAX_RUNGS',        200);  // Nombre max de rungs par programme
define('MAX_TAGS',         500);  // Nombre max de tags

// ─────────────────────────────────────────────
// PATHS
// ─────────────────────────────────────────────
define('ROOT_PATH',    __DIR__);
define('PUBLIC_PATH',  __DIR__ . '/public');
define('VIEWS_PATH',   __DIR__ . '/views');
define('API_PATH',     __DIR__ . '/api');
define('SRC_PATH',     __DIR__ . '/src');
define('SEEDS_PATH',   __DIR__ . '/database/seeds');
