<?php
/**
 * Unified Logger Class
 * Prints database and backend errors to console
 */

class Logger {
    private static $enabled = true;
    private static $logFile = null;

    /**
     * Enable/disable logging
     */
    public static function setEnabled($enabled) {
        self::$enabled = $enabled;
    }

    /**
     * Set log file (optional)
     */
    public static function setLogFile($file) {
        self::$logFile = $file;
    }

    /**
     * Log info message
     */
    public static function info($message, $context = []) {
        self::log('INFO', $message, $context);
    }

    /**
     * Log error message
     */
    public static function error($message, $context = []) {
        self::log('ERROR', $message, $context);
    }

    /**
     * Log warning message
     */
    public static function warning($message, $context = []) {
        self::log('WARNING', $message, $context);
    }

    /**
     * Log debug message
     */
    public static function debug($message, $context = []) {
        self::log('DEBUG', $message, $context);
    }

    /**
     * Log database error
     */
    public static function dbError($message, $query = null, $params = []) {
        $context = [
            'type' => 'DATABASE_ERROR',
            'query' => $query,
            'params' => $params
        ];
        self::log('DB_ERROR', $message, $context);
    }

    /**
     * Log API request
     */
    public static function apiRequest($method, $endpoint, $data = []) {
        if (!self::$enabled) return;

        $context = [
            'method' => $method,
            'endpoint' => $endpoint,
            'data' => $data,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        ];
        self::log('API_REQUEST', "$method $endpoint", $context);
    }

    /**
     * Log API response
     */
    public static function apiResponse($endpoint, $statusCode, $success) {
        if (!self::$enabled) return;

        $context = [
            'endpoint' => $endpoint,
            'status_code' => $statusCode,
            'success' => $success
        ];
        self::log('API_RESPONSE', "Response: $statusCode", $context);
    }

    /**
     * Main log function
     */
    private static function log($level, $message, $context = []) {
        if (!self::$enabled) return;

        $timestamp = date('Y-m-d H:i:s');
        $contextStr = !empty($context) ? json_encode($context, JSON_PRETTY_PRINT) : '';

        // Format log message
        $logMessage = "[$timestamp] [$level] $message";
        if ($contextStr) {
            $logMessage .= "\nContext: $contextStr";
        }
        $logMessage .= "\n" . str_repeat('-', 80) . "\n";

        // Print to console/error log
        error_log($logMessage);

        // Also print to stdout for CLI
        if (php_sapi_name() === 'cli') {
            echo $logMessage;
        }

        // Write to file if specified
        if (self::$logFile !== null) {
            file_put_contents(
                self::$logFile,
                $logMessage,
                FILE_APPEND | LOCK_EX
            );
        }
    }

    /**
     * Log exception
     */
    public static function exception(\Exception $e, $context = []) {
        $context['exception_class'] = get_class($e);
        $context['file'] = $e->getFile();
        $context['line'] = $e->getLine();
        $context['trace'] = $e->getTraceAsString();

        self::error($e->getMessage(), $context);
    }

    /**
     * Log authentication attempt
     */
    public static function authAttempt($email, $success) {
        $context = [
            'email' => $email,
            'success' => $success,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
        ];
        self::log(
            $success ? 'AUTH_SUCCESS' : 'AUTH_FAILED',
            "Authentication attempt for $email",
            $context
        );
    }
}

