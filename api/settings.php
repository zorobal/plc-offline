<?php
/**
 * API — Paramètres utilisateur
 */
header('Content-Type: application/json');

require_once __DIR__ . '/../config.php';
require_once SRC_PATH . '/Database.php';
require_once SRC_PATH . '/Auth.php';

$method = $_SERVER['REQUEST_METHOD'];
$user = Auth::user();
$userId = $user ? $user['id'] : 1;

try {
    $pdo = Database::getInstance();

    switch ($method) {
        case 'GET':
            // Récupérer les paramètres
            $stmt = $pdo->prepare('SELECT * FROM user_settings WHERE user_id = ?');
            $stmt->execute([$userId]);
            $settings = $stmt->fetch();
            
            if ($settings) {
                echo json_encode($settings);
            } else {
                // Créer des paramètres par défaut
                $stmt = $pdo->prepare('INSERT INTO user_settings (user_id) VALUES (?)');
                $stmt->execute([$userId]);
                
                $stmt = $pdo->prepare('SELECT * FROM user_settings WHERE user_id = ?');
                $stmt->execute([$userId]);
                echo json_encode($stmt->fetch());
            }
            break;

        case 'PUT':
            // Mettre à jour les paramètres
            $data = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare('UPDATE user_settings SET theme = ?, layout = ?, language = ?, scan_cycle_ms = ?, ai_enabled = ? WHERE user_id = ?');
            $stmt->execute([
                $data['theme'] ?? 'light',
                $data['layout'] ?? 1,
                $data['language'] ?? 'fr',
                $data['scan_cycle_ms'] ?? 50,
                $data['ai_enabled'] ?? 1,
                $userId
            ]);

            echo json_encode(['success' => true]);
            break;

        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
