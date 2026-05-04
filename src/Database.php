<?php
/**
 * Database Manager — SQLite
 */
class Database
{
    private static ?PDO $instance = null;

    /**
     * Retourne l'instance unique de PDO
     */
    public static function getInstance(): PDO
    {
        if (self::$instance === null) {
            self::$instance = new PDO('sqlite:' . DB_PATH);
            self::$instance->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            self::$instance->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            self::$instance->exec('PRAGMA foreign_keys = ON');
        }
        return self::$instance;
    }

    /**
     * Initialise la base de données (création + seeds)
     */
    public static function init(): void
    {
        // Créer le dossier database s'il n'existe pas
        if (!is_dir(dirname(DB_PATH))) {
            mkdir(dirname(DB_PATH), 0755, true);
        }

        // Charger le schéma
        $sql = file_get_contents(DB_SCHEMA);
        $pdo = self::getInstance();
        $pdo->exec($sql);

        // Seeds initiaux
        self::seedExamples();
        self::seedProblems();
    }

    /**
     * Remplir la table examples
     */
    private static function seedExamples(): void
    {
        $pdo = self::getInstance();
        $stmt = $pdo->query('SELECT COUNT(*) FROM examples');
        if ($stmt->fetchColumn() > 0) {
            return; // Déjà seedé
        }

        $examples = json_decode(file_get_contents(ROOT_PATH . '/examples.json'), true);
        $insert = $pdo->prepare('INSERT INTO examples (order_num, title, description, program, scene, io_devices, instructions_used) VALUES (?, ?, ?, ?, ?, ?, ?)');

        foreach ($examples as $ex) {
            $insert->execute([
                $ex['order'] ?? 0,
                $ex['title'],
                $ex['description'] ?? '',
                json_encode($ex['program']),
                $ex['scene'] ?? null,
                json_encode($ex['io_devices'] ?? []),
                json_encode($ex['instructions_used'] ?? [])
            ]);
        }
    }

    /**
     * Remplir la table problems
     */
    private static function seedProblems(): void
    {
        $pdo = self::getInstance();
        $stmt = $pdo->query('SELECT COUNT(*) FROM problems');
        if ($stmt->fetchColumn() > 0) {
            return; // Déjà seedé
        }

        $problems = json_decode(file_get_contents(ROOT_PATH . '/problems.json'), true);
        $insert = $pdo->prepare('INSERT INTO problems (order_num, title, description, difficulty, scene, io_config, test_vectors, program_template) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');

        foreach ($problems as $pb) {
            $insert->execute([
                $pb['order'] ?? 0,
                $pb['title'],
                $pb['description'],
                $pb['difficulty'] ?? 'EASY',
                $pb['scene'] ?? null,
                json_encode($pb['io_config'] ?? ['inputs' => [], 'outputs' => []]),
                json_encode($pb['test_vectors'] ?? []),
                $pb['program_template'] ? json_encode($pb['program_template']) : null
            ]);
        }
    }
}
