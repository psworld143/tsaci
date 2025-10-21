<?php
/**
 * Simple JWT Implementation
 * Basic JWT encoding/decoding without external dependencies
 */

class SimpleJWT {
    private static $secret_key = "TSACI_SECRET_KEY_2025_SECURE";
    private static $algorithm = 'HS256';

    /**
     * Encode JWT token
     */
    public static function encode($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode($payload);
        
        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        
        $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, self::$secret_key, true);
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        return $base64Header . "." . $base64Payload . "." . $base64Signature;
    }

    /**
     * Decode JWT token
     */
    public static function decode($jwt) {
        $tokenParts = explode('.', $jwt);
        
        if (count($tokenParts) !== 3) {
            throw new Exception('Invalid token format');
        }
        
        $header = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[0])), true);
        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[1])), true);
        $signature = base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[2]));
        
        // Verify signature
        $expectedSignature = hash_hmac('sha256', $tokenParts[0] . "." . $tokenParts[1], self::$secret_key, true);
        
        if (!hash_equals($signature, $expectedSignature)) {
            throw new Exception('Invalid signature');
        }
        
        // Check expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            throw new Exception('Token expired');
        }
        
        return $payload;
    }
}
