<?php
/**
 * API — Communauté (projets partagés)
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
            // Liste des projets partagés
            $stmt = $pdo->query('SELECT p.*, u.username FROM projects p JOIN users u ON p.user_id = u.id WHERE p.is_shared = 1 ORDER BY p.upvotes DESC, p.updated_at DESC');
            $projects = $stmt->fetchAll();
            
            foreach ($projects as &$proj) {
                $proj['program'] = json_decode($proj['program'], true);
                $proj['io_config'] = json_decode($proj['io_config'], true);
            }
            
            echo json_encode($projects);
            break;

        case 'POST':
            // Upvoter un projet
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Missing project ID']);
                break;
            }

            $stmt = $pdo->prepare('UPDATE projects SET upvotes = upvotes + 1 WHERE id = ?');
            $stmt->execute([$_GET['id']]);

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
