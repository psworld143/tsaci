<?php
/**
 * Inventory Model
 */

class Inventory {
    private $conn;
    private $table = 'inventory';

    public $inventory_id;
    public $product_id;
    public $quantity;
    public $location;
    public $minimum_threshold;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Add stock
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . " 
                  (product_id, quantity, location, minimum_threshold) 
                  VALUES (:product_id, :quantity, :location, :minimum_threshold)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':product_id', $this->product_id);
        $stmt->bindParam(':quantity', $this->quantity);
        $stmt->bindParam(':location', $this->location);
        $stmt->bindParam(':minimum_threshold', $this->minimum_threshold);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get all inventory with product details
     */
    public function getAll() {
        $query = "SELECT i.*, p.name as product_name, p.unit 
                  FROM " . $this->table . " i 
                  LEFT JOIN products p ON i.product_id = p.product_id 
                  ORDER BY i.updated_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get inventory by product ID
     */
    public function getByProduct($product_id) {
        $query = "SELECT i.*, p.name as product_name, p.unit 
                  FROM " . $this->table . " i 
                  LEFT JOIN products p ON i.product_id = p.product_id 
                  WHERE i.product_id = :product_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':product_id', $product_id);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get low stock items
     */
    public function getLowStock() {
        $query = "SELECT i.*, p.name as product_name, p.unit 
                  FROM " . $this->table . " i 
                  LEFT JOIN products p ON i.product_id = p.product_id 
                  WHERE i.quantity <= i.minimum_threshold 
                  ORDER BY i.quantity ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Update stock quantity
     */
    public function updateQuantity($product_id, $location, $quantity_change) {
        // First, check if record exists
        $checkQuery = "SELECT inventory_id, quantity FROM " . $this->table . " 
                       WHERE product_id = :product_id AND location = :location LIMIT 1";
        $checkStmt = $this->conn->prepare($checkQuery);
        $checkStmt->bindParam(':product_id', $product_id);
        $checkStmt->bindParam(':location', $location);
        $checkStmt->execute();
        $existing = $checkStmt->fetch();

        if ($existing) {
            // Update existing record
            $new_quantity = $existing['quantity'] + $quantity_change;
            $query = "UPDATE " . $this->table . " 
                      SET quantity = :quantity 
                      WHERE inventory_id = :inventory_id";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':quantity', $new_quantity);
            $stmt->bindParam(':inventory_id', $existing['inventory_id']);
            
            return $stmt->execute();
        } else {
            // Create new record if quantity is positive
            if ($quantity_change > 0) {
                $query = "INSERT INTO " . $this->table . " 
                          (product_id, quantity, location) 
                          VALUES (:product_id, :quantity, :location)";
                
                $stmt = $this->conn->prepare($query);
                $stmt->bindParam(':product_id', $product_id);
                $stmt->bindParam(':quantity', $quantity_change);
                $stmt->bindParam(':location', $location);
                
                return $stmt->execute();
            }
        }

        return false;
    }

    /**
     * Update inventory
     */
    public function update() {
        $query = "UPDATE " . $this->table . " 
                  SET quantity = :quantity, 
                      location = :location, 
                      minimum_threshold = :minimum_threshold 
                  WHERE inventory_id = :inventory_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':quantity', $this->quantity);
        $stmt->bindParam(':location', $this->location);
        $stmt->bindParam(':minimum_threshold', $this->minimum_threshold);
        $stmt->bindParam(':inventory_id', $this->inventory_id);

        return $stmt->execute();
    }

    /**
     * Delete inventory
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE inventory_id = :inventory_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':inventory_id', $this->inventory_id);

        return $stmt->execute();
    }
}

