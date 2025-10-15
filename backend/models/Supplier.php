<?php
/**
 * Supplier Model
 */

class Supplier {
    private $conn;
    private $table = 'suppliers';

    public $supplier_id;
    public $name;
    public $contact;
    public $address;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create supplier
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
     * Get all suppliers
     */
    public function getAll() {
        $query = "SELECT * FROM " . $this->table . " ORDER BY name ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get supplier by ID
     */
    public function getById($id) {
        $query = "SELECT * FROM " . $this->table . " WHERE supplier_id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Update supplier
     */
    public function update() {
        $query = "UPDATE " . $this->table . " 
                  SET name = :name, 
                      contact = :contact, 
                      address = :address 
                  WHERE supplier_id = :supplier_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':name', $this->name);
        $stmt->bindParam(':contact', $this->contact);
        $stmt->bindParam(':address', $this->address);
        $stmt->bindParam(':supplier_id', $this->supplier_id);

        return $stmt->execute();
    }

    /**
     * Delete supplier
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE supplier_id = :supplier_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':supplier_id', $this->supplier_id);

        return $stmt->execute();
    }
}

