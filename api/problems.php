<?php
/**
 * API — Problèmes / Challenges
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
            if (isset($_GET['id'])) {
                // Un problème spécifique
                $stmt = $pdo->prepare('SELECT * FROM problems WHERE id = ?');
                $stmt->execute([$_GET['id']]);
                $problem = $stmt->fetch();
                
                if ($problem) {
                    $problem['io_config'] = json_decode($problem['io_config'], true);
                    $problem['test_vectors'] = json_decode($problem['test_vectors'], true);
                    $problem['program_template'] = $problem['program_template'] ? json_decode($problem['program_template'], true) : null;
                    
                    // Vérifier si déjà complété
                    $stmt = $pdo->prepare('SELECT * FROM completions WHERE user_id = ? AND problem_id = ?');
                    $stmt->execute([$userId, $_GET['id']]);
                    $problem['completed'] = (bool)$stmt->fetch();
                    
                    echo json_encode($problem);
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Problem not found']);
                }
            } else {
                // Liste de tous les problèmes
                $stmt = $pdo->query('SELECT * FROM problems ORDER BY order_num');
                $problems = $stmt->fetchAll();
                
                foreach ($problems as &$pb) {
                    $pb['io_config'] = json_decode($pb['io_config'], true);
                    $pb['test_vectors'] = json_decode($pb['test_vectors'], true);
                    $pb['program_template'] = $pb['program_template'] ? json_decode($pb['program_template'], true) : null;
                    
                    // Vérifier si complété
                    $stmt = $pdo->prepare('SELECT id FROM completions WHERE user_id = ? AND problem_id = ?');
                    $stmt->execute([$userId, $pb['id']]);
                    $pb['completed'] = (bool)$stmt->fetch();
                }
                
                echo json_encode($problems);
            }
            break;

        case 'POST':
            // Soumettre une solution
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Missing problem ID']);
                break;
            }

            $data = json_decode(file_get_contents('php://input'), true);
            $program = $data['program'] ?? ['tags' => [], 'rungs' => []];

            // TODO: Valider la solution avec les test vectors
            
            // Enregistrer la tentative
            $stmt = $pdo->prepare('INSERT OR REPLACE INTO completions (user_id, problem_id, program, attempts) VALUES (?, ?, ?, COALESCE((SELECT attempts FROM completions WHERE user_id = ? AND problem_id = ?), 0) + 1)');
            $stmt->execute([$userId, $_GET['id'], json_encode($program), $userId, $_GET['id']]);

            // Pour l'instant, on considère que c'est validé
            echo json_encode([
                'success' => true,
                'message' => 'Solution enregistrée'
            ]);
            break;

        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
