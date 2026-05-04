<?php
/**
 * API — Authentification
 */
header('Content-Type: application/json');

require_once __DIR__ . '/../config.php';
require_once SRC_PATH . '/Database.php';
require_once SRC_PATH . '/Auth.php';

$method = $_SERVER['REQUEST_METHOD'];

try {
    switch ($method) {
        case 'POST':
            // Déterminer l'action
            $action = $_GET['action'] ?? '';
            $data = json_decode(file_get_contents('php://input'), true);

            switch ($action) {
                case 'signin':
                    $username = $data['username'] ?? '';
                    $password = $data['password'] ?? '';
                    
                    if (empty($username) || empty($password)) {
                        http_response_code(400);
                        echo json_encode(['success' => false, 'error' => 'Username and password required']);
                        break;
                    }

                    if (Auth::login($username, $password)) {
                        echo json_encode([
                            'success' => true,
                            'user' => Auth::user()
                        ]);
                    } else {
                        http_response_code(401);
                        echo json_encode(['success' => false, 'error' => 'Invalid credentials']);
                    }
                    break;

                case 'signup':
                    $username = $data['username'] ?? '';
                    $email = $data['email'] ?? '';
                    $password = $data['password'] ?? '';
                    
                    if (empty($username) || empty($password)) {
                        http_response_code(400);
                        echo json_encode(['success' => false, 'error' => 'Username and password required']);
                        break;
                    }

                    $result = Auth::register($username, $email, $password);
                    
                    if ($result['success']) {
                        echo json_encode([
                            'success' => true,
                            'user' => Auth::user()
                        ]);
                    } else {
                        http_response_code(400);
                        echo json_encode(['success' => false, 'error' => $result['error']]);
                    }
                    break;

                case 'signout':
                    Auth::logout();
                    echo json_encode(['success' => true]);
                    break;

                default:
                    http_response_code(400);
                    echo json_encode(['error' => 'Unknown action']);
            }
            break;

        case 'GET':
            // Récupérer l'utilisateur courant
            $user = Auth::user();
            
            if ($user) {
                echo json_encode(['user' => $user]);
            } else {
                echo json_encode(['user' => null]);
            }
            break;

        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
