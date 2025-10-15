<?php
/**
 * Expense Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Expense.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $expense = new Expense($db);
    
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 100;
    $expenses = $expense->getAll($limit);
    
    Logger::info("Expenses retrieved", ['count' => count($expenses)]);
    Response::success("Expenses retrieved", $expenses);
}

function getById($id) {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $expense = new Expense($db);
    
    $expenseData = $expense->getById($id);
    
    if ($expenseData) {
        Response::success("Expense retrieved", $expenseData);
    } else {
        Response::error("Expense not found", 404);
    }
}

function create() {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (!isset($data['category']) || !isset($data['amount']) || !isset($data['date'])) {
        Response::error("Category, amount, and date are required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $expense = new Expense($db);
    
    $expense->category = $data['category'];
    $expense->amount = $data['amount'];
    $expense->date = $data['date'];
    $expense->description = isset($data['description']) ? $data['description'] : null;
    $expense->department = isset($data['department']) ? $data['department'] : null;
    
    $expense_id = $expense->create();
    
    if ($expense_id) {
        Logger::info("Expense created", ['expense_id' => $expense_id, 'amount' => $data['amount']]);
        Response::success("Expense created successfully", ['expense_id' => $expense_id], 201);
    } else {
        Logger::error("Failed to create expense");
        Response::error("Failed to create expense", 500);
    }
}

function filterByDate() {
    JWTAuth::verifyToken();
    
    $start_date = isset($_GET['start_date']) ? $_GET['start_date'] : null;
    $end_date = isset($_GET['end_date']) ? $_GET['end_date'] : null;
    
    if (!$start_date || !$end_date) {
        Response::error("Start date and end date are required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $expense = new Expense($db);
    
    $expenses = $expense->getByDateRange($start_date, $end_date);
    
    Response::success("Expenses retrieved", $expenses);
}

function filterByCategory() {
    JWTAuth::verifyToken();
    
    $category = isset($_GET['category']) ? $_GET['category'] : null;
    
    if (!$category) {
        Response::error("Category is required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $expense = new Expense($db);
    
    $expenses = $expense->getByCategory($category);
    
    Response::success("Expenses retrieved", $expenses);
}

function update($id) {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $expense = new Expense($db);
    
    $expense->expense_id = $id;
    $expense->category = $data['category'];
    $expense->amount = $data['amount'];
    $expense->date = $data['date'];
    $expense->description = isset($data['description']) ? $data['description'] : null;
    $expense->department = isset($data['department']) ? $data['department'] : null;
    
    if ($expense->update()) {
        Logger::info("Expense updated", ['expense_id' => $id]);
        Response::success("Expense updated successfully");
    } else {
        Logger::error("Failed to update expense", ['expense_id' => $id]);
        Response::error("Failed to update expense", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $expense = new Expense($db);
    
    $expense->expense_id = $id;
    
    if ($expense->delete()) {
        Logger::info("Expense deleted", ['expense_id' => $id]);
        Response::success("Expense deleted successfully");
    } else {
        Logger::error("Failed to delete expense", ['expense_id' => $id]);
        Response::error("Failed to delete expense", 500);
    }
}

// Handle expense routes
if (isset($action)) {
    switch ($action) {
        case 'getAll':
            getAll();
            break;
        case 'getById':
            if (isset($param)) getById($param);
            else Response::error("Expense ID is required");
            break;
        case 'create':
            create();
            break;
        case 'filterByDate':
            filterByDate();
            break;
        case 'filterByCategory':
            filterByCategory();
            break;
        case 'update':
            if (isset($param)) update($param);
            else Response::error("Expense ID is required");
            break;
        case 'delete':
            if (isset($param)) delete($param);
            else Response::error("Expense ID is required");
            break;
        default:
            Response::error("Invalid action");
    }
}
