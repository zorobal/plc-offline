<?php
/**
 * Router HTTP simple — Front Controller
 */
class Router
{
    private array $routes = [];

    public function get(string $path, string $handler): void
    {
        $this->routes[] = ['GET', $path, $handler];
    }

    public function post(string $path, string $handler): void
    {
        $this->routes[] = ['POST', $path, $handler];
    }

    public function put(string $path, string $handler): void
    {
        $this->routes[] = ['PUT', $path, $handler];
    }

    public function delete(string $path, string $handler): void
    {
        $this->routes[] = ['DELETE', $path, $handler];
    }

    public function dispatch(): void
    {
        $method = $_SERVER['REQUEST_METHOD'];
        $uri    = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

        // Retirer le base path si sous-dossier
        $basePath = dirname($_SERVER['SCRIPT_NAME']);
        if ($basePath !== '/' && str_starts_with($uri, $basePath)) {
            $uri = substr($uri, strlen($basePath));
        }
        $uri = '/' . ltrim($uri, '/');

        foreach ($this->routes as [$routeMethod, $routePath, $handler]) {
            // Convertir {param} en regex
            $pattern = preg_replace('/\{([^}]+)\}/', '(?P<$1>[^/]+)', $routePath);
            $pattern = '#^' . $pattern . '$#';

            if ($routeMethod === $method && preg_match($pattern, $uri, $matches)) {
                // Paramètres de route
                $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
                $_GET = array_merge($_GET, $params);

                // Inclure le handler
                $handlerPath = ROOT_PATH . '/' . $handler;
                if (file_exists($handlerPath)) {
                    require $handlerPath;
                } else {
                    $this->notFound();
                }
                return;
            }
        }

        $this->notFound();
    }

    private function notFound(): void
    {
        // Si c'est une requête API, retourner JSON
        $uri = $_SERVER['REQUEST_URI'];
        if (str_contains($uri, '/api/')) {
            http_response_code(404);
            header('Content-Type: application/json');
            echo json_encode(['error' => 'Endpoint not found']);
        } else {
            http_response_code(404);
            require ROOT_PATH . '/views/404.php';
        }
    }
}
