<?php
/**
 * Client API Mistral AI
 */
class MistralClient
{
    private string $apiKey;
    private string $apiUrl;
    private string $model;
    private int $maxTokens;
    private float $temperature;

    public function __construct()
    {
        $this->apiKey = MISTRAL_API_KEY;
        $this->apiUrl = MISTRAL_API_URL;
        $this->model = MISTRAL_MODEL;
        $this->maxTokens = MISTRAL_MAX_TOKENS;
        $this->temperature = MISTRAL_TEMPERATURE;
    }

    /**
     * Envoie un message à l'API Mistral et retourne la réponse
     * 
     * @param array $messages Tableau de messages [{role, content}, ...]
     * @return array Réponse décodée JSON
     * @throws Exception En cas d'erreur API
     */
    public function chat(array $messages): array
    {
        $payload = [
            'model' => $this->model,
            'messages' => $messages,
            'max_tokens' => $this->maxTokens,
            'temperature' => $this->temperature,
        ];

        $ch = curl_init($this->apiUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Authorization: Bearer ' . $this->apiKey
        ]);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            throw new Exception('Curl error: ' . $error);
        }

        if ($httpCode !== 200) {
            $data = json_decode($response, true);
            $errorMsg = $data['message'] ?? 'Unknown API error';
            throw new Exception('Mistral API error (' . $httpCode . '): ' . $errorMsg);
        }

        return json_decode($response, true);
    }

    /**
     * Chat simple avec une seule question
     * 
     * @param string $question La question de l'utilisateur
     * @param string|null $systemPrompt Prompt système optionnel
     * @return string La réponse de l'IA
     */
    public function ask(string $question, ?string $systemPrompt = null): string
    {
        $messages = [];

        if ($systemPrompt) {
            $messages[] = ['role' => 'system', 'content' => $systemPrompt];
        }

        $messages[] = ['role' => 'user', 'content' => $question];

        $response = $this->chat($messages);
        return $response['choices'][0]['message']['content'] ?? '';
    }

    /**
     * Génère un programme ladder à partir d'une description
     * 
     * @param string $description Description du comportement souhaité
     * @return array Programme au format JSON {tags, rungs}
     */
    public function generateLadder(string $description): array
    {
        $systemPrompt = <<<'PROMPT'
Tu es un expert en automates programmables (PLC).
Génère un programme ladder logic au format JSON strict avec cette structure :
{
  "tags": [{"name": "TAG1", "type": "bool", "address": "%I0.0"}],
  "rungs": [{"comment": "", "instructions": [{"type": "LD", "operand": "TAG1"}]}]
}

Types d'instructions supportés : LD, AND, OR, NOT, ST, TON, CTU, RS, SET, RST.
Réponds UNIQUEMENT avec le JSON, sans texte autour.
PROMPT;

        $response = $this->ask($description, $systemPrompt);
        
        // Extraire le JSON de la réponse
        if (preg_match('/\{.*\}/s', $response, $matches)) {
            return json_decode($matches[0], true) ?? ['tags' => [], 'rungs' => []];
        }
        
        return ['tags' => [], 'rungs' => []];
    }

    /**
     * Explique un programme ladder
     * 
     * @param array $program Programme ladder {tags, rungs}
     * @return string Explication textuelle
     */
    public function explain(array $program): string
    {
        $systemPrompt = "Tu es un expert en automates programmables. Explique clairement le fonctionnement du programme ladder fourni.";
        
        $programJson = json_encode($program, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        $question = "Explique ce programme ladder :\n\n" . $programJson;

        return $this->ask($question, $systemPrompt);
    }

    /**
     * Debugge un programme ladder
     * 
     * @param array $program Programme ladder
     * @param string $problemDescription Description du problème
     * @return string Suggestions de correction
     */
    public function debug(array $program, string $problemDescription): string
    {
        $systemPrompt = "Tu es un expert en débogage de programmes PLC. Analyse le programme et propose des corrections.";
        
        $programJson = json_encode($program, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        $question = "Voici un programme ladder qui pose problème :\n\n" . $programJson . "\n\nProblème rencontré : " . $problemDescription . "\n\nPropose une analyse et des corrections.";

        return $this->ask($question, $systemPrompt);
    }

    /**
     * Sauvegarde l'historique de conversation dans la base de données
     */
    public function saveHistory(int $userId, string $sessionId, string $role, string $content, int $tokens = 0): void
    {
        $pdo = Database::getInstance();
        $stmt = $pdo->prepare('INSERT INTO ai_history (user_id, session_id, role, content, tokens) VALUES (?, ?, ?, ?, ?)');
        $stmt->execute([$userId, $sessionId, $role, $content, $tokens]);
    }

    /**
     * Récupère l'historique de conversation
     */
    public function getHistory(int $userId, string $sessionId, int $limit = 20): array
    {
        $pdo = Database::getInstance();
        $stmt = $pdo->prepare('SELECT role, content FROM ai_history WHERE user_id = ? AND session_id = ? ORDER BY created_at DESC LIMIT ?');
        $stmt->execute([$userId, $sessionId, $limit]);
        return array_reverse($stmt->fetchAll());
    }

    /**
     * Efface l'historique de conversation
     */
    public function clearHistory(int $userId, ?string $sessionId = null): void
    {
        $pdo = Database::getInstance();
        
        if ($sessionId) {
            $stmt = $pdo->prepare('DELETE FROM ai_history WHERE user_id = ? AND session_id = ?');
            $stmt->execute([$userId, $sessionId]);
        } else {
            $stmt = $pdo->prepare('DELETE FROM ai_history WHERE user_id = ?');
            $stmt->execute([$userId]);
        }
    }
}
