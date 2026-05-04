<?php
/**
 * PLCIOsim Offline — Point d'entrée unique
 * Tout passe par ce fichier (Front Controller pattern)
 */

require_once __DIR__ . '/config.php';
require_once SRC_PATH . '/Router.php';
require_once SRC_PATH . '/Database.php';
require_once SRC_PATH . '/Auth.php';

// Démarrer la session
session_name(SESSION_NAME);
session_start();

// Initialiser la DB si elle n'existe pas
if (!file_exists(DB_PATH)) {
    Database::init();
}

// Gérer les erreurs en dev
if (APP_DEBUG) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

// ─────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────
$router = new Router();

// Pages HTML
$router->get('/',            'views/editor.php');
$router->get('/projects',    'views/projects.php');
$router->get('/examples',    'views/examples.php');
$router->get('/community',   'views/community.php');
$router->get('/problems',    'views/problems.php');
$router->get('/settings',    'views/settings.php');
$router->get('/signin',      'views/signin.php');
$router->get('/signup',      'views/signup.php');
$router->get('/help',        'views/help.php');

// API REST — Projects
$router->get('/api/projects',            'api/projects.php');
$router->post('/api/projects',           'api/projects.php');
$router->put('/api/projects/{id}',       'api/projects.php');
$router->delete('/api/projects/{id}',    'api/projects.php');

// API REST — Examples
$router->get('/api/examples',            'api/examples.php');
$router->get('/api/examples/{id}',       'api/examples.php');

// API REST — Problems
$router->get('/api/problems',            'api/problems.php');
$router->get('/api/problems/{id}',       'api/problems.php');
$router->post('/api/problems/{id}/submit', 'api/problems.php');

// API REST — Community
$router->get('/api/community',           'api/community.php');
$router->post('/api/community/{id}/upvote', 'api/community.php');

// API REST — Auth
$router->post('/api/auth/signin',        'api/auth.php');
$router->post('/api/auth/signup',        'api/auth.php');
$router->post('/api/auth/signout',       'api/auth.php');
$router->get('/api/auth/me',             'api/auth.php');

// API REST — Settings
$router->get('/api/settings',            'api/settings.php');
$router->put('/api/settings',            'api/settings.php');

// API REST — Mistral AI
$router->post('/api/ai/chat',            'api/ai.php');
$router->post('/api/ai/generate-ladder', 'api/ai.php');
$router->post('/api/ai/explain',         'api/ai.php');
$router->post('/api/ai/debug',           'api/ai.php');
$router->delete('/api/ai/history',       'api/ai.php');

// Dispatcher
$router->dispatch();
