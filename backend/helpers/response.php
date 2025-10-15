<?php
/**
 * Response Helper Functions
 * Standardized JSON responses
 */

require_once __DIR__ . '/logger.php';

class Response {
    
    /**
     * Set CORS headers
     */
    private static function setCorsHeaders() {
        if (!headers_sent()) {
            header('Access-Control-Allow-Origin: *');
            header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
            header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin');
            header('Access-Control-Allow-Credentials: true');
        }
    }
    
    /**
     * Send JSON response
     */
    public static function json($data, $status_code = 200) {
        self::setCorsHeaders();
        http_response_code($status_code);
        header('Content-Type: application/json; charset=UTF-8');
        echo json_encode($data);
        exit;
    }

    /**
     * Send success response
     */
    public static function success($message, $data = null, $status_code = 200) {
        Logger::apiResponse($_SERVER['REQUEST_URI'] ?? 'unknown', $status_code, true);
        
        self::json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $status_code);
    }

    /**
     * Send error response
     */
    public static function error($message, $status_code = 400, $errors = null) {
        Logger::error($message, [
            'status_code' => $status_code,
            'errors' => $errors,
            'endpoint' => $_SERVER['REQUEST_URI'] ?? 'unknown'
        ]);
        
        Logger::apiResponse($_SERVER['REQUEST_URI'] ?? 'unknown', $status_code, false);
        
        self::json([
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ], $status_code);
    }

    /**
     * Send unauthorized response
     */
    public static function unauthorized($message = "Unauthorized access") {
        self::error($message, 401);
    }

    /**
     * Send not found response
     */
    public static function notFound($message = "Resource not found") {
        self::error($message, 404);
    }

    /**
     * Send validation error response
     */
    public static function validationError($errors) {
        self::error("Validation failed", 422, $errors);
    }
}

