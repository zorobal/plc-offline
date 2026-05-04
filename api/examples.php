<?php
/**
 * API — Exemples
 */
header('Content-Type: application/json');

require_once __DIR__ . '/../config.php';
require_once SRC_PATH . '/Database.php';

$method = $_SERVER['REQUEST_METHOD'];

try {
    $pdo = Database::getInstance();

    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Un exemple spécifique
                $stmt = $pdo->prepare('SELECT * FROM examples WHERE id = ?');
                $stmt->execute([$_GET['id']]);
                $example = $stmt->fetch();
                
                if ($example) {
                    $example['program'] = json_decode($example['program'], true);
                    $example['io_devices'] = json_decode($example['io_devices'], true);
                    $example['instructions_used'] = json_decode($example['instructions_used'], true);
                    echo json_encode($example);
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Example not found']);
                }
            } else {
                // Liste de tous les exemples
                $stmt = $pdo->query('SELECT * FROM examples ORDER BY order_num');
                $examples = $stmt->fetchAll();
                
                foreach ($examples as &$ex) {
                    $ex['program'] = json_decode($ex['program'], true);
                    $ex['io_devices'] = json_decode($ex['io_devices'], true);
                    $ex['instructions_used'] = json_decode($ex['instructions_used'], true);
                }
                
                echo json_encode($examples);
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
