<?php
/**
 * Production Model
 */

class Production {
    private $conn;
    private $table = 'production';

    public $production_id;
    public $product_id;
    public $supervisor_id;
    public $input_qty;
    public $output_qty;
    public $date;
    public $notes;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create production log
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . " 
                  (product_id, supervisor_id, input_qty, output_qty, date, notes) 
                  VALUES (:product_id, :supervisor_id, :input_qty, :output_qty, :date, :notes)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':product_id', $this->product_id);
        $stmt->bindParam(':supervisor_id', $this->supervisor_id);
        $stmt->bindParam(':input_qty', $this->input_qty);
        $stmt->bindParam(':output_qty', $this->output_qty);
        $stmt->bindParam(':date', $this->date);
        $stmt->bindParam(':notes', $this->notes);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get all production logs with product and supervisor details
     */
    public function getAll($limit = 100) {
        $query = "SELECT p.*, prod.name as product_name, u.name as supervisor_name 
                  FROM " . $this->table . " p 
                  LEFT JOIN products prod ON p.product_id = prod.product_id 
                  LEFT JOIN users u ON p.supervisor_id = u.user_id 
                  ORDER BY p.date DESC, p.created_at DESC 
                  LIMIT :limit";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get production by ID
     */
    public function getById($id) {
        $query = "SELECT p.*, prod.name as product_name, u.name as supervisor_name 
                  FROM " . $this->table . " p 
                  LEFT JOIN products prod ON p.product_id = prod.product_id 
                  LEFT JOIN users u ON p.supervisor_id = u.user_id 
                  WHERE p.production_id = :id LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Filter by date range
     */
    public function getByDateRange($start_date, $end_date) {
        $query = "SELECT p.*, prod.name as product_name, u.name as supervisor_name 
                  FROM " . $this->table . " p 
                  LEFT JOIN products prod ON p.product_id = prod.product_id 
                  LEFT JOIN users u ON p.supervisor_id = u.user_id 
                  WHERE p.date BETWEEN :start_date AND :end_date 
                  ORDER BY p.date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Filter by product type
     */
    public function getByProduct($product_id) {
        $query = "SELECT p.*, prod.name as product_name, u.name as supervisor_name 
                  FROM " . $this->table . " p 
                  LEFT JOIN products prod ON p.product_id = prod.product_id 
                  LEFT JOIN users u ON p.supervisor_id = u.user_id 
                  WHERE p.product_id = :product_id 
                  ORDER BY p.date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':product_id', $product_id);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Update production log
     */
    public function update() {
        $query = "UPDATE " . $this->table . " 
                  SET product_id = :product_id, 
                      supervisor_id = :supervisor_id, 
                      input_qty = :input_qty, 
                      output_qty = :output_qty, 
                      date = :date, 
                      notes = :notes 
                  WHERE production_id = :production_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':product_id', $this->product_id);
        $stmt->bindParam(':supervisor_id', $this->supervisor_id);
        $stmt->bindParam(':input_qty', $this->input_qty);
        $stmt->bindParam(':output_qty', $this->output_qty);
        $stmt->bindParam(':date', $this->date);
        $stmt->bindParam(':notes', $this->notes);
        $stmt->bindParam(':production_id', $this->production_id);

        return $stmt->execute();
    }

    /**
     * Delete production log
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE production_id = :production_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':production_id', $this->production_id);

        return $stmt->execute();
    }
}

