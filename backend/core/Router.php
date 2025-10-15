<?php
/**
 * Router Class
 * Handles dynamic routing for REST API
 */

class Router {
    private $routes = [];
    private $baseUrl;

    public function __construct($baseUrl = '/backend') {
        $this->baseUrl = $baseUrl;
    }

    /**
     * Add GET route
     */
    public function get($path, $callback) {
        $this->addRoute('GET', $path, $callback);
    }

    /**
     * Add POST route
     */
    public function post($path, $callback) {
        $this->addRoute('POST', $path, $callback);
    }

    /**
     * Add PUT route
     */
    public function put($path, $callback) {
        $this->addRoute('PUT', $path, $callback);
    }

    /**
     * Add DELETE route
     */
    public function delete($path, $callback) {
        $this->addRoute('DELETE', $path, $callback);
    }

    /**
     * Add route to routes array
     */
    private function addRoute($method, $path, $callback) {
        $this->routes[] = [
            'method' => $method,
            'path' => $path,
            'callback' => $callback
        ];
    }

    /**
     * Resolve and execute route
     */
    public function resolve() {
        $method = $_SERVER['REQUEST_METHOD'];
        $uri = $_SERVER['REQUEST_URI'];
        
        // Remove query string
        $uri = strtok($uri, '?');
        
        // Remove base URL from path
        $path = str_replace($this->baseUrl, '', $uri);
        
        // Ensure path starts with /
        if (substr($path, 0, 1) !== '/') {
            $path = '/' . $path;
        }

        foreach ($this->routes as $route) {
            if ($route['method'] === $method) {
                $pattern = $this->convertToRegex($route['path']);
                
                if (preg_match($pattern, $path, $matches)) {
                    array_shift($matches); // Remove full match
                    
                    // Call the callback with matched parameters
                    return call_user_func_array($route['callback'], $matches);
                }
            }
        }

        // No route found
        Response::notFound("Route not found");
    }

    /**
     * Convert route path to regex pattern
     */
    private function convertToRegex($path) {
        // Replace :param with named capture group
        $pattern = preg_replace('/\{([a-zA-Z0-9_]+)\}/', '([a-zA-Z0-9_-]+)', $path);
        return '#^' . $pattern . '$#';
    }

    /**
     * Get JSON input from request body
     */
    public static function getJsonInput() {
        $input = file_get_contents('php://input');
        $decoded = json_decode($input, true);
        
        // Return empty array if no input instead of null
        return $decoded ?? [];
    }

    /**
     * Get request headers
     */
    public static function getHeaders() {
        return getallheaders();
    }
}

