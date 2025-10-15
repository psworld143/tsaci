<?php
/**
 * Sales Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Sale.php';
require_once __DIR__ . '/../models/Inventory.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $sale = new Sale($db);
    
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 100;
    $sales = $sale->getAll($limit);
    
    Logger::info("Sales retrieved", ['count' => count($sales)]);
    Response::success("Sales retrieved", $sales);
}

function getById($id) {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $sale = new Sale($db);
    
    $saleData = $sale->getById($id);
    
    if ($saleData) {
        Response::success("Sale retrieved", $saleData);
    } else {
        Response::error("Sale not found", 404);
    }
}

function create() {
    JWTAuth::verifyToken();
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (!isset($data['customer_id']) || !isset($data['product_id']) || !isset($data['quantity']) || !isset($data['unit_price'])) {
        Response::error("Customer ID, product ID, quantity, and unit price are required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $sale = new Sale($db);
    $inventory = new Inventory($db);
    
    // Calculate total amount
    $total_amount = $data['quantity'] * $data['unit_price'];
    
    $sale->customer_id = $data['customer_id'];
    $sale->product_id = $data['product_id'];
    $sale->quantity = $data['quantity'];
    $sale->unit_price = $data['unit_price'];
    $sale->total_amount = $total_amount;
    $sale->status = isset($data['status']) ? $data['status'] : 'pending';
    $sale->date = isset($data['date']) ? $data['date'] : date('Y-m-d');
    
    $sale_id = $sale->create();
    
    if ($sale_id) {
        // Update inventory if sale is completed
        if ($sale->status === 'completed') {
            $location = isset($data['location']) ? $data['location'] : 'Main Warehouse';
            $inventory->updateQuantity($data['product_id'], $location, -$data['quantity']);
        }
        
        Logger::info("Sale created", ['sale_id' => $sale_id, 'total_amount' => $total_amount]);
        Response::success("Sale created successfully", [
            'sale_id' => $sale_id,
            'total_amount' => $total_amount
        ], 201);
    } else {
        Logger::error("Failed to create sale");
        Response::error("Failed to create sale", 500);
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
    $sale = new Sale($db);
    
    $sales = $sale->getByDateRange($start_date, $end_date);
    
    Response::success("Sales retrieved", $sales);
}

function update($id) {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $sale = new Sale($db);
    $inventory = new Inventory($db);
    
    // Get existing sale to check status change
    $existingSale = $sale->getById($id);
    
    $total_amount = $data['quantity'] * $data['unit_price'];
    
    $sale->sale_id = $id;
    $sale->customer_id = $data['customer_id'];
    $sale->product_id = $data['product_id'];
    $sale->quantity = $data['quantity'];
    $sale->unit_price = $data['unit_price'];
    $sale->total_amount = $total_amount;
    $sale->status = $data['status'];
    $sale->date = $data['date'];
    
    if ($sale->update()) {
        // Update inventory if status changed to completed
        if ($existingSale['status'] !== 'completed' && $data['status'] === 'completed') {
            $location = isset($data['location']) ? $data['location'] : 'Main Warehouse';
            $inventory->updateQuantity($data['product_id'], $location, -$data['quantity']);
        }
        
        Logger::info("Sale updated", ['sale_id' => $id]);
        Response::success("Sale updated successfully");
    } else {
        Logger::error("Failed to update sale", ['sale_id' => $id]);
        Response::error("Failed to update sale", 500);
    }
}

function updateStatus($id) {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['status'])) {
        Response::error("Status is required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $sale = new Sale($db);
    
    if ($sale->updateStatus($id, $data['status'])) {
        Logger::info("Sale status updated", ['sale_id' => $id, 'status' => $data['status']]);
        Response::success("Sale status updated successfully");
    } else {
        Logger::error("Failed to update sale status", ['sale_id' => $id]);
        Response::error("Failed to update sale status", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $sale = new Sale($db);
    
    $sale->sale_id = $id;
    
    if ($sale->delete()) {
        Logger::info("Sale deleted", ['sale_id' => $id]);
        Response::success("Sale deleted successfully");
    } else {
        Logger::error("Failed to delete sale", ['sale_id' => $id]);
        Response::error("Failed to delete sale", 500);
    }
}

// Handle sales routes
if (isset($action)) {
    switch ($action) {
        case 'getAll':
            getAll();
            break;
        case 'getById':
            if (isset($param)) getById($param);
            else Response::error("Sale ID is required");
            break;
        case 'create':
            create();
            break;
        case 'filterByDate':
            filterByDate();
            break;
        case 'update':
            if (isset($param)) update($param);
            else Response::error("Sale ID is required");
            break;
        case 'updateStatus':
            if (isset($param)) updateStatus($param);
            else Response::error("Sale ID is required");
            break;
        case 'delete':
            if (isset($param)) delete($param);
            else Response::error("Sale ID is required");
            break;
        default:
            Response::error("Invalid action");
    }
}
