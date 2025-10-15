<?php
/**
 * Production Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Production.php';
require_once __DIR__ . '/../models/Inventory.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 100;
    $logs = $production->getAll($limit);
    
    Logger::info("Production logs retrieved", ['count' => count($logs)]);
    Response::success("Production logs retrieved", $logs);
}

function getById($id) {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    
    $log = $production->getById($id);
    
    if ($log) {
        Response::success("Production log retrieved", $log);
    } else {
        Response::error("Production log not found", 404);
    }
}

function create() {
    $user = JWTAuth::verifyToken();
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (!isset($data['product_id']) || !isset($data['input_qty']) || !isset($data['output_qty']) || !isset($data['date'])) {
        Response::error("Product ID, input quantity, output quantity, and date are required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    $inventory = new Inventory($db);
    
    // Set production data
    $production->product_id = $data['product_id'];
    $production->supervisor_id = $user->user_id;
    $production->input_qty = $data['input_qty'];
    $production->output_qty = $data['output_qty'];
    $production->date = $data['date'];
    $production->notes = isset($data['notes']) ? $data['notes'] : null;
    
    // Create production log
    $production_id = $production->create();
    
    if ($production_id) {
        // Update inventory - add output quantity
        $location = isset($data['location']) ? $data['location'] : 'Main Warehouse';
        $inventory->updateQuantity($data['product_id'], $location, $data['output_qty']);
        
        Logger::info("Production log created", [
            'production_id' => $production_id,
            'product_id' => $data['product_id'],
            'supervisor_id' => $user->user_id,
            'output_qty' => $data['output_qty']
        ]);
        
        Response::success("Production log created successfully", ['production_id' => $production_id], 201);
    } else {
        Logger::error("Failed to create production log", [
            'product_id' => $data['product_id'],
            'supervisor_id' => $user->user_id
        ]);
        Response::error("Failed to create production log", 500);
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
    $production = new Production($db);
    
    $logs = $production->getByDateRange($start_date, $end_date);
    
    Response::success("Production logs retrieved", $logs);
}

function filterByProduct() {
    JWTAuth::verifyToken();
    
    $product_id = isset($_GET['product_id']) ? $_GET['product_id'] : null;
    
    if (!$product_id) {
        Response::error("Product ID is required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    
    $logs = $production->getByProduct($product_id);
    
    Response::success("Production logs retrieved", $logs);
}

function update($id) {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    
    $production->production_id = $id;
    $production->product_id = $data['product_id'];
    $production->supervisor_id = $data['supervisor_id'];
    $production->input_qty = $data['input_qty'];
    $production->output_qty = $data['output_qty'];
    $production->date = $data['date'];
    $production->notes = isset($data['notes']) ? $data['notes'] : null;
    
    if ($production->update()) {
        Logger::info("Production log updated", ['production_id' => $id]);
        Response::success("Production log updated successfully");
    } else {
        Logger::error("Failed to update production log", ['production_id' => $id]);
        Response::error("Failed to update production log", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    
    $production->production_id = $id;
    
    if ($production->delete()) {
        Logger::info("Production log deleted", ['production_id' => $id]);
        Response::success("Production log deleted successfully");
    } else {
        Logger::error("Failed to delete production log", ['production_id' => $id]);
        Response::error("Failed to delete production log", 500);
    }
}

// Handle production routes
if (isset($action)) {
    switch ($action) {
        case 'getAll':
            getAll();
            break;
        case 'getById':
            if (isset($param)) getById($param);
            else Response::error("Production ID is required");
            break;
        case 'create':
            create();
            break;
        case 'filterByDate':
            filterByDate();
            break;
        case 'filterByProduct':
            filterByProduct();
            break;
        case 'update':
            if (isset($param)) update($param);
            else Response::error("Production ID is required");
            break;
        case 'delete':
            if (isset($param)) delete($param);
            else Response::error("Production ID is required");
            break;
        default:
            Response::error("Invalid action");
    }
}
