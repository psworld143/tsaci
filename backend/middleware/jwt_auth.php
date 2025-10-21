<?php
/**
 * JWT Authentication Middleware
 */

require_once __DIR__ . '/../helpers/simple_jwt.php';
require_once __DIR__ . '/../helpers/logger.php';

class JWTAuth {
    private static $secret_key = "TSACI_SECRET_KEY_2025_SECURE";
    private static $issuer = "tsaci-system";
    private static $audience = "tsaci-users";
    private static $algorithm = 'HS256';

    /**
     * Generate JWT token
     */
    public static function generateToken($user_id, $email, $role) {
        $issued_at = time();
        $expiration = $issued_at + (60 * 60 * 24 * 7); // 7 days

        $payload = [
            'iss' => self::$issuer,
            'aud' => self::$audience,
            'iat' => $issued_at,
            'exp' => $expiration,
            'data' => [
                'user_id' => $user_id,
                'email' => $email,
                'role' => $role
            ]
        ];

        return SimpleJWT::encode($payload);
    }

    /**
     * Verify JWT token
     */
    public static function verifyToken() {
        $headers = getallheaders();
        $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : 
                     (isset($headers['authorization']) ? $headers['authorization'] : null);

        if (!$authHeader) {
            Logger::warning("Authentication failed: No token provided", [
                'endpoint' => $_SERVER['REQUEST_URI'] ?? 'unknown'
            ]);
            Response::unauthorized("No authorization token provided");
        }

        // Extract token from "Bearer TOKEN" format
        $token = str_replace('Bearer ', '', $authHeader);

        try {
            $decoded = SimpleJWT::decode($token);
            return (object) $decoded['data'];
        } catch (Exception $e) {
            Logger::error("JWT verification failed: " . $e->getMessage(), [
                'endpoint' => $_SERVER['REQUEST_URI'] ?? 'unknown',
                'token_preview' => substr($token, 0, 20) . '...'
            ]);
            Response::unauthorized("Invalid or expired token: " . $e->getMessage());
        }
    }

    /**
     * Check if user has required role
     */
    public static function requireRole($required_roles) {
        $user = self::verifyToken();
        
        if (!in_array($user->role, $required_roles)) {
            Response::error("Access denied. Insufficient permissions.", 403);
        }

        return $user;
    }

    /**
     * Get current authenticated user
     */
    public static function getCurrentUser() {
        return self::verifyToken();
    }
}

