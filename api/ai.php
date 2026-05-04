<?php
/**
 * API — Intégration Mistral AI
 */
header('Content-Type: application/json');

require_once __DIR__ . '/../config.php';
require_once SRC_PATH . '/Database.php';
require_once SRC_PATH . '/Auth.php';
require_once SRC_PATH . '/MistralClient.php';

$method = $_SERVER['REQUEST_METHOD'];
$user = Auth::user();
$userId = $user ? $user['id'] : 1;

// Session ID pour l'historique
$sessionId = $_POST['session_id'] ?? session_id();

try {
    $client = new MistralClient();

    switch ($method) {
        case 'POST':
            // Déterminer le type de requête
            $action = $_GET['action'] ?? 'chat';
            $data = json_decode(file_get_contents('php://input'), true);

            switch ($action) {
                case 'chat':
                    // Chat général avec l'IA
                    $messages = $data['messages'] ?? [];
                    
                    if (empty($messages)) {
                        http_response_code(400);
                        echo json_encode(['error' => 'No messages provided']);
                        break;
                    }

                    // Sauvegarder le message utilisateur
                    $lastUserMessage = end($messages);
                    if ($lastUserMessage['role'] === 'user') {
                        $client->saveHistory($userId, $sessionId, 'user', $lastUserMessage['content']);
                    }

                    // Appel API
                    $response = $client->chat($messages);
                    $answer = $response['choices'][0]['message']['content'] ?? '';
                    $tokens = $response['usage']['total_tokens'] ?? 0;

                    // Sauvegarder la réponse
                    $client->saveHistory($userId, $sessionId, 'assistant', $answer, $tokens);

                    echo json_encode([
                        'success' => true,
                        'response' => $answer,
                        'tokens' => $tokens,
                        'session_id' => $sessionId
                    ]);
                    break;

                case 'generate-ladder':
                    // Générer un programme ladder
                    $description = $data['description'] ?? '';
                    
                    if (empty($description)) {
                        http_response_code(400);
                        echo json_encode(['error' => 'No description provided']);
                        break;
                    }

                    $program = $client->generateLadder($description);
                    
                    // Sauvegarder dans l'historique
                    $client->saveHistory($userId, $sessionId, 'user', 'Génère un programme : ' . $description);
                    $client->saveHistory($userId, $sessionId, 'assistant', json_encode($program));

                    echo json_encode([
                        'success' => true,
                        'program' => $program,
                        'session_id' => $sessionId
                    ]);
                    break;

                case 'explain':
                    // Expliquer un programme
                    $program = $data['program'] ?? [];
                    
                    if (empty($program)) {
                        http_response_code(400);
                        echo json_encode(['error' => 'No program provided']);
                        break;
                    }

                    $explanation = $client->explain($program);
                    
                    $client->saveHistory($userId, $sessionId, 'user', 'Explique ce programme : ' . json_encode($program));
                    $client->saveHistory($userId, $sessionId, 'assistant', $explanation);

                    echo json_encode([
                        'success' => true,
                        'explanation' => $explanation,
                        'session_id' => $sessionId
                    ]);
                    break;

                case 'debug':
                    // Debugger un programme
                    $program = $data['program'] ?? [];
                    $problem = $data['problem'] ?? '';
                    
                    if (empty($program) || empty($problem)) {
                        http_response_code(400);
                        echo json_encode(['error' => 'Program and problem description required']);
                        break;
                    }

                    $debug = $client->debug($program, $problem);
                    
                    $client->saveHistory($userId, $sessionId, 'user', 'Debug : ' . $problem . ' - ' . json_encode($program));
                    $client->saveHistory($userId, $sessionId, 'assistant', $debug);

                    echo json_encode([
                        'success' => true,
                        'debug' => $debug,
                        'session_id' => $sessionId
                    ]);
                    break;

                default:
                    http_response_code(400);
                    echo json_encode(['error' => 'Unknown action']);
            }
            break;

        case 'DELETE':
            // Effacer l'historique
            $client->clearHistory($userId, $sessionId);
            echo json_encode(['success' => true]);
            break;

        case 'GET':
            // Récupérer l'historique
            $history = $client->getHistory($userId, $sessionId);
            echo json_encode(['history' => $history]);
            break;

        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'error' => $e->getMessage(),
        'type' => get_class($e)
    ]);
}
