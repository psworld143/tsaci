<?php
/**
 * Inventory Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Inventory.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $inventory = new Inventory($db);
    
    $items = $inventory->getAll();
    Logger::info("Inventory retrieved", ['count' => count($items)]);
    
    Response::success("Inventory retrieved", $items);
}

function getByProduct($product_id) {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $inventory = new Inventory($db);
    
    $items = $inventory->getByProduct($product_id);
    
    Response::success("Inventory retrieved", $items);
}

function getLowStock() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $inventory = new Inventory($db);
    
    $items = $inventory->getLowStock();
    Logger::info("Low stock items retrieved", ['count' => count($items)]);
    
    Response::success("Low stock items retrieved", $items);
}

function create() {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (!isset($data['product_id']) || !isset($data['quantity'])) {
        Response::error("Product ID and quantity are required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $inventory = new Inventory($db);
    
    $inventory->product_id = $data['product_id'];
    $inventory->quantity = $data['quantity'];
    $inventory->location = isset($data['location']) ? $data['location'] : 'Main Warehouse';
    $inventory->minimum_threshold = isset($data['minimum_threshold']) ? $data['minimum_threshold'] : 10;
    
    $inventory_id = $inventory->create();
    
    if ($inventory_id) {
        Logger::info("Inventory added", ['inventory_id' => $inventory_id, 'product_id' => $data['product_id']]);
        Response::success("Inventory added successfully", ['inventory_id' => $inventory_id], 201);
    } else {
        Logger::error("Failed to add inventory", ['product_id' => $data['product_id']]);
        Response::error("Failed to add inventory", 500);
    }
}

function update($id) {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $inventory = new Inventory($db);
    
    $inventory->inventory_id = $id;
    $inventory->quantity = $data['quantity'];
    $inventory->location = isset($data['location']) ? $data['location'] : 'Main Warehouse';
    $inventory->minimum_threshold = isset($data['minimum_threshold']) ? $data['minimum_threshold'] : 10;
    
    if ($inventory->update()) {
        Logger::info("Inventory updated", ['inventory_id' => $id]);
        Response::success("Inventory updated successfully");
    } else {
        Logger::error("Failed to update inventory", ['inventory_id' => $id]);
        Response::error("Failed to update inventory", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $inventory = new Inventory($db);
    
    $inventory->inventory_id = $id;
    
    if ($inventory->delete()) {
        Logger::info("Inventory deleted", ['inventory_id' => $id]);
        Response::success("Inventory deleted successfully");
    } else {
        Logger::error("Failed to delete inventory", ['inventory_id' => $id]);
        Response::error("Failed to delete inventory", 500);
    }
}

// Handle inventory routes
if (isset($action)) {
    switch ($action) {
        case 'getAll':
            getAll();
            break;
        case 'getByProduct':
            if (isset($param)) getByProduct($param);
            else Response::error("Product ID is required");
            break;
        case 'getLowStock':
            getLowStock();
            break;
        case 'create':
            create();
            break;
        case 'update':
            if (isset($param)) update($param);
            else Response::error("Inventory ID is required");
            break;
        case 'delete':
            if (isset($param)) delete($param);
            else Response::error("Inventory ID is required");
            break;
        default:
            Response::error("Invalid action");
    }
}
