<?php
/**
 * API — Gestion des projets
 */
header('Content-Type: application/json');

require_once __DIR__ . '/../config.php';
require_once SRC_PATH . '/Database.php';
require_once SRC_PATH . '/Auth.php';

$method = $_SERVER['REQUEST_METHOD'];
$user = Auth::user();
$userId = $user ? $user['id'] : 1; // Utilisateur local par défaut

try {
    $pdo = Database::getInstance();

    switch ($method) {
        case 'GET':
            // Liste tous les projets ou un seul
            if (isset($_GET['id'])) {
                $stmt = $pdo->prepare('SELECT * FROM projects WHERE id = ? AND (user_id = ? OR is_shared = 1)');
                $stmt->execute([$_GET['id'], $userId]);
                $project = $stmt->fetch();
                echo json_encode($project ?: ['error' => 'Project not found']);
            } else {
                $stmt = $pdo->prepare('SELECT id, title, description, created_at, updated_at, is_shared, upvotes FROM projects WHERE user_id = ? OR is_shared = 1 ORDER BY updated_at DESC');
                $stmt->execute([$userId]);
                $projects = $stmt->fetchAll();
                echo json_encode($projects);
            }
            break;

        case 'POST':
            // Créer un nouveau projet
            $data = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare('INSERT INTO projects (user_id, title, description, program, scene, io_config) VALUES (?, ?, ?, ?, ?, ?)');
            $stmt->execute([
                $userId,
                $data['title'] ?? 'Nouveau projet',
                $data['description'] ?? '',
                json_encode($data['program'] ?? ['tags' => [], 'rungs' => []]),
                $data['scene'] ?? null,
                json_encode($data['io_config'] ?? ['inputs' => [], 'outputs' => []])
            ]);

            echo json_encode([
                'success' => true,
                'id' => $pdo->lastInsertId()
            ]);
            break;

        case 'PUT':
            // Mettre à jour un projet existant
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Missing project ID']);
                break;
            }

            $data = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare('UPDATE projects SET title = ?, description = ?, program = ?, scene = ?, io_config = ?, is_shared = ? WHERE id = ? AND user_id = ?');
            $stmt->execute([
                $data['title'] ?? 'Projet',
                $data['description'] ?? '',
                json_encode($data['program'] ?? ['tags' => [], 'rungs' => []]),
                $data['scene'] ?? null,
                json_encode($data['io_config'] ?? ['inputs' => [], 'outputs' => []]),
                $data['is_shared'] ?? 0,
                $_GET['id'],
                $userId
            ]);

            echo json_encode(['success' => true]);
            break;

        case 'DELETE':
            // Supprimer un projet
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Missing project ID']);
                break;
            }

            $stmt = $pdo->prepare('DELETE FROM projects WHERE id = ? AND user_id = ?');
            $stmt->execute([$_GET['id'], $userId]);

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
