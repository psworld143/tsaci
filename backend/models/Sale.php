<?php
/**
 * Sale Model
 */

class Sale {
    private $conn;
    private $table = 'sales';

    public $sale_id;
    public $customer_id;
    public $product_id;
    public $quantity;
    public $unit_price;
    public $total_amount;
    public $status;
    public $date;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create sale
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . " 
                  (customer_id, product_id, quantity, unit_price, total_amount, status, date) 
                  VALUES (:customer_id, :product_id, :quantity, :unit_price, :total_amount, :status, :date)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':customer_id', $this->customer_id);
        $stmt->bindParam(':product_id', $this->product_id);
        $stmt->bindParam(':quantity', $this->quantity);
        $stmt->bindParam(':unit_price', $this->unit_price);
        $stmt->bindParam(':total_amount', $this->total_amount);
        $stmt->bindParam(':status', $this->status);
        $stmt->bindParam(':date', $this->date);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get all sales with customer and product details
     */
    public function getAll($limit = 100) {
        $query = "SELECT s.*, c.name as customer_name, p.name as product_name, p.unit 
                  FROM " . $this->table . " s 
                  LEFT JOIN customers c ON s.customer_id = c.customer_id 
                  LEFT JOIN products p ON s.product_id = p.product_id 
                  ORDER BY s.date DESC, s.created_at DESC 
                  LIMIT :limit";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get sale by ID
     */
    public function getById($id) {
        $query = "SELECT s.*, c.name as customer_name, p.name as product_name, p.unit 
                  FROM " . $this->table . " s 
                  LEFT JOIN customers c ON s.customer_id = c.customer_id 
                  LEFT JOIN products p ON s.product_id = p.product_id 
                  WHERE s.sale_id = :id LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Filter by date range
     */
    public function getByDateRange($start_date, $end_date) {
        $query = "SELECT s.*, c.name as customer_name, p.name as product_name, p.unit 
                  FROM " . $this->table . " s 
                  LEFT JOIN customers c ON s.customer_id = c.customer_id 
                  LEFT JOIN products p ON s.product_id = p.product_id 
                  WHERE s.date BETWEEN :start_date AND :end_date 
                  ORDER BY s.date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get total sales amount for a period
     */
    public function getTotalSales($start_date, $end_date) {
        $query = "SELECT SUM(total_amount) as total_sales 
                  FROM " . $this->table . " 
                  WHERE date BETWEEN :start_date AND :end_date 
                  AND status = 'completed'";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->execute();

        $result = $stmt->fetch();
        return $result['total_sales'] ?? 0;
    }

    /**
     * Update sale
     */
    public function update() {
        $query = "UPDATE " . $this->table . " 
                  SET customer_id = :customer_id, 
                      product_id = :product_id, 
                      quantity = :quantity, 
                      unit_price = :unit_price, 
                      total_amount = :total_amount, 
                      status = :status, 
                      date = :date 
                  WHERE sale_id = :sale_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':customer_id', $this->customer_id);
        $stmt->bindParam(':product_id', $this->product_id);
        $stmt->bindParam(':quantity', $this->quantity);
        $stmt->bindParam(':unit_price', $this->unit_price);
        $stmt->bindParam(':total_amount', $this->total_amount);
        $stmt->bindParam(':status', $this->status);
        $stmt->bindParam(':date', $this->date);
        $stmt->bindParam(':sale_id', $this->sale_id);

        return $stmt->execute();
    }

    /**
     * Update sale status
     */
    public function updateStatus($sale_id, $status) {
        $query = "UPDATE " . $this->table . " SET status = :status WHERE sale_id = :sale_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':status', $status);
        $stmt->bindParam(':sale_id', $sale_id);

        return $stmt->execute();
    }

    /**
     * Delete sale
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE sale_id = :sale_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':sale_id', $this->sale_id);

        return $stmt->execute();
    }
}

