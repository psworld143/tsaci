<?php
/**
 * Product Model
 */

class Product {
    private $conn;
    private $table = 'products';

    public $product_id;
    public $name;
    public $category;
    public $price;
    public $unit;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create product
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . " 
                  (name, category, price, unit) 
                  VALUES (:name, :category, :price, :unit)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':name', $this->name);
        $stmt->bindParam(':category', $this->category);
        $stmt->bindParam(':price', $this->price);
        $stmt->bindParam(':unit', $this->unit);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get all products
     */
    public function getAll() {
        $query = "SELECT * FROM " . $this->table . " ORDER BY name ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get product by ID
     */
    public function getById($id) {
        $query = "SELECT * FROM " . $this->table . " WHERE product_id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Get products by category
     */
    public function getByCategory($category) {
        $query = "SELECT * FROM " . $this->table . " 
                  WHERE category = :category 
                  ORDER BY name ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':category', $category);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Update product
     */
    public function update() {
        $query = "UPDATE " . $this->table . " 
                  SET name = :name, 
                      category = :category, 
                      price = :price, 
                      unit = :unit 
                  WHERE product_id = :product_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':name', $this->name);
        $stmt->bindParam(':category', $this->category);
        $stmt->bindParam(':price', $this->price);
        $stmt->bindParam(':unit', $this->unit);
        $stmt->bindParam(':product_id', $this->product_id);

        return $stmt->execute();
    }

    /**
     * Delete product
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE product_id = :product_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':product_id', $this->product_id);

        return $stmt->execute();
    }
}

