<?php
/**
 * Gestion de l'authentification
 */
class Auth
{
    /**
     * Vérifie si l'utilisateur est connecté
     */
    public static function isLoggedIn(): bool
    {
        return isset($_SESSION['user_id']);
    }

    /**
     * Retourne l'utilisateur connecté
     */
    public static function user(): ?array
    {
        if (!self::isLoggedIn()) {
            return null;
        }

        $pdo = Database::getInstance();
        $stmt = $pdo->prepare('SELECT id, username, email, role FROM users WHERE id = ?');
        $stmt->execute([$_SESSION['user_id']]);
        $user = $stmt->fetch();

        return $user ?: null;
    }

    /**
     * Connecte un utilisateur
     */
    public static function login(string $username, string $password): bool
    {
        $pdo = Database::getInstance();
        $stmt = $pdo->prepare('SELECT * FROM users WHERE username = ? OR email = ?');
        $stmt->execute([$username, $username]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password'])) {
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['username'] = $user['username'];
            return true;
        }

        return false;
    }

    /**
     * Inscrit un nouvel utilisateur
     */
    public static function register(string $username, string $email, string $password): array
    {
        $pdo = Database::getInstance();

        // Vérifier si l'utilisateur existe déjà
        $stmt = $pdo->prepare('SELECT id FROM users WHERE username = ? OR email = ?');
        $stmt->execute([$username, $email]);
        if ($stmt->fetch()) {
            return ['success' => false, 'error' => 'Username or email already exists'];
        }

        // Hasher le mot de passe
        $hashed = password_hash($password, PASSWORD_BCRYPT, ['cost' => BCRYPT_ROUNDS]);

        // Insérer l'utilisateur
        $insert = $pdo->prepare('INSERT INTO users (username, email, password) VALUES (?, ?, ?)');
        $insert->execute([$username, $email, $hashed]);

        // Connexion automatique
        $_SESSION['user_id'] = $pdo->lastInsertId();
        $_SESSION['username'] = $username;

        return ['success' => true];
    }

    /**
     * Déconnecte l'utilisateur
     */
    public static function logout(): void
    {
        session_destroy();
        session_start();
    }

    /**
     * Génère un token CSRF
     */
    public static function generateCsrfToken(): string
    {
        if (empty($_SESSION[CSRF_TOKEN_NAME])) {
            $_SESSION[CSRF_TOKEN_NAME] = bin2hex(random_bytes(32));
        }
        return $_SESSION[CSRF_TOKEN_NAME];
    }

    /**
     * Vérifie un token CSRF
     */
    public static function verifyCsrfToken(?string $token): bool
    {
        return isset($_SESSION[CSRF_TOKEN_NAME]) && hash_equals($_SESSION[CSRF_TOKEN_NAME], $token ?? '');
    }
}
