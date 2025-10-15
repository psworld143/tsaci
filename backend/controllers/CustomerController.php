<?php
/**
 * Customer Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Customer.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $customer = new Customer($db);
    
    $customers = $customer->getAll();
    
    Logger::info("Customers retrieved", ['count' => count($customers)]);
    Response::success("Customers retrieved", $customers);
}

function getById($id) {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $customer = new Customer($db);
    
    $customerData = $customer->getById($id);
    
    if ($customerData) {
        Response::success("Customer retrieved", $customerData);
    } else {
        Response::error("Customer not found", 404);
    }
}

function create() {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (!isset($data['name'])) {
        Response::error("Name is required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $customer = new Customer($db);
    
    $customer->name = $data['name'];
    $customer->contact = isset($data['contact']) ? $data['contact'] : null;
    $customer->address = isset($data['address']) ? $data['address'] : null;
    
    $customer_id = $customer->create();
    
    if ($customer_id) {
        Logger::info("Customer created", ['customer_id' => $customer_id, 'name' => $data['name']]);
        Response::success("Customer created successfully", ['customer_id' => $customer_id], 201);
    } else {
        Logger::error("Failed to create customer");
        Response::error("Failed to create customer", 500);
    }
}

function update($id) {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $customer = new Customer($db);
    
    $customer->customer_id = $id;
    $customer->name = $data['name'];
    $customer->contact = isset($data['contact']) ? $data['contact'] : null;
    $customer->address = isset($data['address']) ? $data['address'] : null;
    
    if ($customer->update()) {
        Logger::info("Customer updated", ['customer_id' => $id]);
        Response::success("Customer updated successfully");
    } else {
        Logger::error("Failed to update customer", ['customer_id' => $id]);
        Response::error("Failed to update customer", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $customer = new Customer($db);
    
    $customer->customer_id = $id;
    
    if ($customer->delete()) {
        Logger::info("Customer deleted", ['customer_id' => $id]);
        Response::success("Customer deleted successfully");
    } else {
        Logger::error("Failed to delete customer", ['customer_id' => $id]);
        Response::error("Failed to delete customer", 500);
    }
}

// Handle customer routes
if (isset($action)) {
    switch ($action) {
        case 'getAll':
            getAll();
            break;
        case 'getById':
            if (isset($param)) getById($param);
            else Response::error("Customer ID is required");
            break;
        case 'create':
            create();
            break;
        case 'update':
            if (isset($param)) update($param);
            else Response::error("Customer ID is required");
            break;
        case 'delete':
            if (isset($param)) delete($param);
            else Response::error("Customer ID is required");
            break;
        default:
            Response::error("Invalid action");
    }
}
