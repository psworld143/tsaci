<?php
/**
 * CORS Configuration
 * Cross-Origin Resource Sharing settings
 */

class CorsConfig {
    
    /**
     * Allowed origins
     * For production, replace '*' with specific domains
     */
    public static $allowed_origins = ['*'];
    
    /**
     * Allowed HTTP methods
     */
    public static $allowed_methods = ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'];
    
    /**
     * Allowed headers
     */
    public static $allowed_headers = [
        'Content-Type',
        'Authorization',
        'X-Requested-With',
        'Accept',
        'Origin',
        'X-Api-Key'
    ];
    
    /**
     * Exposed headers
     */
    public static $exposed_headers = [
        'Content-Length',
        'Content-Type',
        'Authorization'
    ];
    
    /**
     * Max age for preflight cache (in seconds)
     */
    public static $max_age = 86400; // 24 hours
    
    /**
     * Allow credentials
     */
    public static $allow_credentials = true;
    
    /**
     * Apply CORS headers
     */
    public static function apply() {
        // Get the origin of the request
        $origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';
        
        // Check if origin is allowed
        if (self::isOriginAllowed($origin)) {
            header('Access-Control-Allow-Origin: ' . $origin);
        } elseif (in_array('*', self::$allowed_origins)) {
            header('Access-Control-Allow-Origin: *');
        }
        
        // Set other CORS headers
        header('Access-Control-Allow-Methods: ' . implode(', ', self::$allowed_methods));
        header('Access-Control-Allow-Headers: ' . implode(', ', self::$allowed_headers));
        header('Access-Control-Expose-Headers: ' . implode(', ', self::$exposed_headers));
        header('Access-Control-Max-Age: ' . self::$max_age);
        
        if (self::$allow_credentials) {
            header('Access-Control-Allow-Credentials: true');
        }
        
        // Handle preflight OPTIONS request
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit();
        }
    }
    
    /**
     * Check if origin is allowed
     */
    private static function isOriginAllowed($origin) {
        if (in_array('*', self::$allowed_origins)) {
            return true;
        }
        
        return in_array($origin, self::$allowed_origins);
    }
    
    /**
     * Add allowed origin
     */
    public static function addAllowedOrigin($origin) {
        if (!in_array($origin, self::$allowed_origins)) {
            self::$allowed_origins[] = $origin;
        }
    }
    
    /**
     * Set allowed origins for production
     * Example: CorsConfig::setProductionOrigins(['https://tsaci.com', 'https://app.tsaci.com'])
     */
    public static function setProductionOrigins($origins) {
        self::$allowed_origins = $origins;
    }
}

