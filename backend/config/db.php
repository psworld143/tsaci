<?php
/**
 * Database Configuration
 * PDO Connection for MySQL
 */

require_once __DIR__ . '/../helpers/logger.php';

class Database {
    private $host = "127.0.0.1";
    private $db_name = "tsaci_db";
    private $username = "root";
    private $password = "";
    private $port = "3306";
    private $conn;

    /**
     * Get database connection
     * @return PDO|null
     */
    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";port=" . $this->port . ";dbname=" . $this->db_name,
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
            
            Logger::info("Database connection established", [
                'database' => $this->db_name,
                'host' => $this->host
            ]);
        } catch(PDOException $e) {
            Logger::dbError(
                "Database connection failed: " . $e->getMessage(),
                null,
                [
                    'host' => $this->host,
                    'database' => $this->db_name,
                    'port' => $this->port
                ]
            );
            echo "Connection Error: " . $e->getMessage();
        }

        return $this->conn;
    }
}

