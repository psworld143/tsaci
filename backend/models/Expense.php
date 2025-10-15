<?php
/**
 * Expense Model
 */

class Expense {
    private $conn;
    private $table = 'expenses';

    public $expense_id;
    public $category;
    public $amount;
    public $date;
    public $description;
    public $department;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create expense
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . " 
                  (category, amount, date, description, department) 
                  VALUES (:category, :amount, :date, :description, :department)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':category', $this->category);
        $stmt->bindParam(':amount', $this->amount);
        $stmt->bindParam(':date', $this->date);
        $stmt->bindParam(':description', $this->description);
        $stmt->bindParam(':department', $this->department);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get all expenses
     */
    public function getAll($limit = 100) {
        $query = "SELECT * FROM " . $this->table . " 
                  ORDER BY date DESC, created_at DESC 
                  LIMIT :limit";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get expense by ID
     */
    public function getById($id) {
        $query = "SELECT * FROM " . $this->table . " WHERE expense_id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch();
    }

    /**
     * Filter by date range
     */
    public function getByDateRange($start_date, $end_date) {
        $query = "SELECT * FROM " . $this->table . " 
                  WHERE date BETWEEN :start_date AND :end_date 
                  ORDER BY date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Filter by category
     */
    public function getByCategory($category) {
        $query = "SELECT * FROM " . $this->table . " 
                  WHERE category = :category 
                  ORDER BY date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':category', $category);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Get total expenses for a period
     */
    public function getTotalExpenses($start_date, $end_date) {
        $query = "SELECT SUM(amount) as total_expenses 
                  FROM " . $this->table . " 
                  WHERE date BETWEEN :start_date AND :end_date";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->execute();

        $result = $stmt->fetch();
        return $result['total_expenses'] ?? 0;
    }

    /**
     * Get expenses by category for a period
     */
    public function getExpensesByCategory($start_date, $end_date) {
        $query = "SELECT category, SUM(amount) as total 
                  FROM " . $this->table . " 
                  WHERE date BETWEEN :start_date AND :end_date 
                  GROUP BY category 
                  ORDER BY total DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Update expense
     */
    public function update() {
        $query = "UPDATE " . $this->table . " 
                  SET category = :category, 
                      amount = :amount, 
                      date = :date, 
                      description = :description, 
                      department = :department 
                  WHERE expense_id = :expense_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':category', $this->category);
        $stmt->bindParam(':amount', $this->amount);
        $stmt->bindParam(':date', $this->date);
        $stmt->bindParam(':description', $this->description);
        $stmt->bindParam(':department', $this->department);
        $stmt->bindParam(':expense_id', $this->expense_id);

        return $stmt->execute();
    }

    /**
     * Delete expense
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table . " WHERE expense_id = :expense_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':expense_id', $this->expense_id);

        return $stmt->execute();
    }
}

