<?php
/**
 * Customer Model
 */

class Customer {
    private $conn;
    private $table = 'customers';

    public $customer_id;
    public $name;
    public $contact;
    public $address;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create customer
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . " 
                  (name, contact, address) 
                  VALUES (:name, :contact, :address)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':name', $this->name);
        $stmt->bindParam(':contact', $this->contact);
        $stmt->bindParam(':address', $this->address);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get all customers
     */
    public function getAll() {
        $query = "SELECT * FROM " . $this->table . " ORDER BY name ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get customer by ID
     */
    public function getById($id) {
        $query = "SELECT * FROM " . $this->table . " WHERE customer_id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Update customer
     */
    public function update() {
        $query = "UPDATE " . $this->table . " 
                  SET name = :name, 
                      contact = :contact, 
                      address = :address 
                  WHERE customer_id = :customer_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':name', $this->name);
        $stmt->bindParam(':contact', $this->contact);
        $stmt->bindParam(':address', $this->address);
        $stmt->bindParam(':customer_id', $this->customer_id);

        return $stmt->execute();
    }

    /**
     * Delete customer
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE customer_id = :customer_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':customer_id', $this->customer_id);

        return $stmt->execute();
    }
}

