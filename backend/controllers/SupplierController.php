<?php
/**
 * Supplier Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Supplier.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $supplier = new Supplier($db);
    
    $suppliers = $supplier->getAll();
    
    Logger::info("Suppliers retrieved", ['count' => count($suppliers)]);
    Response::success("Suppliers retrieved", $suppliers);
}

function getById($id) {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $supplier = new Supplier($db);
    
    $supplierData = $supplier->getById($id);
    
    if ($supplierData) {
        Response::success("Supplier retrieved", $supplierData);
    } else {
        Response::error("Supplier not found", 404);
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
    $supplier = new Supplier($db);
    
    $supplier->name = $data['name'];
    $supplier->contact = isset($data['contact']) ? $data['contact'] : null;
    $supplier->address = isset($data['address']) ? $data['address'] : null;
    
    $supplier_id = $supplier->create();
    
    if ($supplier_id) {
        Logger::info("Supplier created", ['supplier_id' => $supplier_id, 'name' => $data['name']]);
        Response::success("Supplier created successfully", ['supplier_id' => $supplier_id], 201);
    } else {
        Logger::error("Failed to create supplier");
        Response::error("Failed to create supplier", 500);
    }
}

function update($id) {
    JWTAuth::requireRole(['admin', 'manager', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $supplier = new Supplier($db);
    
    $supplier->supplier_id = $id;
    $supplier->name = $data['name'];
    $supplier->contact = isset($data['contact']) ? $data['contact'] : null;
    $supplier->address = isset($data['address']) ? $data['address'] : null;
    
    if ($supplier->update()) {
        Logger::info("Supplier updated", ['supplier_id' => $id]);
        Response::success("Supplier updated successfully");
    } else {
        Logger::error("Failed to update supplier", ['supplier_id' => $id]);
        Response::error("Failed to update supplier", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $supplier = new Supplier($db);
    
    $supplier->supplier_id = $id;
    
    if ($supplier->delete()) {
        Logger::info("Supplier deleted", ['supplier_id' => $id]);
        Response::success("Supplier deleted successfully");
    } else {
        Logger::error("Failed to delete supplier", ['supplier_id' => $id]);
        Response::error("Failed to delete supplier", 500);
    }
}

// Handle supplier routes
if (isset($action)) {
    switch ($action) {
        case 'getAll':
            getAll();
            break;
        case 'getById':
            if (isset($param)) getById($param);
            else Response::error("Supplier ID is required");
            break;
        case 'create':
            create();
            break;
        case 'update':
            if (isset($param)) update($param);
            else Response::error("Supplier ID is required");
            break;
        case 'delete':
            if (isset($param)) delete($param);
            else Response::error("Supplier ID is required");
            break;
        default:
            Response::error("Invalid action");
    }
}
