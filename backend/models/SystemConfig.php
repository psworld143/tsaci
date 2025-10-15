<?php
/**
 * System Config Model
 */

class SystemConfig {
    private $conn;
    private $table = 'system_config';

    public $config_id;
    public $config_key;
    public $config_value;
    public $config_type;
    public $description;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Get all configurations
     */
    public function getAll() {
        $query = "SELECT * FROM " . $this->table . " ORDER BY config_key";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get config by key
     */
    public function getByKey($key) {
        $query = "SELECT * FROM " . $this->table . " WHERE config_key = :key LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':key', $key);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Update or create configuration
     */
    public function upsert($key, $value, $type = 'text', $description = null) {
        $query = "INSERT INTO " . $this->table . " 
                  (config_key, config_value, config_type, description) 
                  VALUES (:key, :value, :type, :description)
                  ON DUPLICATE KEY UPDATE 
                  config_value = :value2, 
                  config_type = :type2,
                  description = :description2";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':key', $key);
        $stmt->bindParam(':value', $value);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':description', $description);
        $stmt->bindParam(':value2', $value);
        $stmt->bindParam(':type2', $type);
        $stmt->bindParam(':description2', $description);

        return $stmt->execute();
    }

    /**
     * Delete configuration
     */
    public function delete($key) {
        $query = "DELETE FROM " . $this->table . " WHERE config_key = :key";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':key', $key);

        return $stmt->execute();
    }
}

