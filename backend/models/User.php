<?php
/**
 * User Model
 */

class User {
    private $conn;
    private $table = 'users';

    public $user_id;
    public $name;
    public $email;
    public $role;
    public $password_hash;
    public $password; // Alias for password_hash

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create new user
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . " 
                  (name, email, role, password_hash) 
                  VALUES (:name, :email, :role, :password_hash)";

        $stmt = $this->conn->prepare($query);

        // Use password or password_hash
        $pwd = $this->password ?? $this->password_hash;

        $stmt->bindParam(':name', $this->name);
        $stmt->bindParam(':email', $this->email);
        $stmt->bindParam(':role', $this->role);
        $stmt->bindParam(':password_hash', $pwd);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get user by email
     */
    public function getByEmail($email) {
        $query = "SELECT * FROM " . $this->table . " WHERE email = :email LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Get user by ID
     */
    public function getById($id) {
        $query = "SELECT user_id, name, email, role, created_at, updated_at 
                  FROM " . $this->table . " WHERE user_id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Get all users
     */
    public function getAll() {
        $query = "SELECT user_id, name, email, role, created_at, updated_at 
                  FROM " . $this->table . " ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Update user
     */
    public function update() {
        // Check if password needs to be updated
        if (isset($this->password) && !empty($this->password)) {
            $query = "UPDATE " . $this->table . " 
                      SET name = :name, email = :email, role = :role, password_hash = :password_hash 
                      WHERE user_id = :user_id";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':name', $this->name);
            $stmt->bindParam(':email', $this->email);
            $stmt->bindParam(':role', $this->role);
            $stmt->bindParam(':password_hash', $this->password);
            $stmt->bindParam(':user_id', $this->user_id);
        } else {
            $query = "UPDATE " . $this->table . " 
                      SET name = :name, email = :email, role = :role 
                      WHERE user_id = :user_id";

            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':name', $this->name);
            $stmt->bindParam(':email', $this->email);
            $stmt->bindParam(':role', $this->role);
            $stmt->bindParam(':user_id', $this->user_id);
        }

        return $stmt->execute();
    }
    
    /**
     * Check if email exists
     */
    public function emailExists($email) {
        $query = "SELECT user_id FROM " . $this->table . " WHERE email = :email LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }
    
    /**
     * Update user role
     */
    public function updateRole($user_id, $role) {
        $query = "UPDATE " . $this->table . " SET role = :role WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':role', $role);
        $stmt->bindParam(':user_id', $user_id);
        
        return $stmt->execute();
    }
    
    /**
     * Reset user password
     */
    public function resetPassword($user_id, $new_password_hash) {
        $query = "UPDATE " . $this->table . " SET password_hash = :password_hash WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':password_hash', $new_password_hash);
        $stmt->bindParam(':user_id', $user_id);
        
        return $stmt->execute();
    }

    /**
     * Delete user
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $this->user_id);

        return $stmt->execute();
    }

    /**
     * Verify password
     */
    public function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
}

