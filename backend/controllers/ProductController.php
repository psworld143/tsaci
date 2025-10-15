<?php
/**
 * Product Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Product.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $product = new Product($db);
    
    $products = $product->getAll();
    
    Logger::info("Products retrieved", ['count' => count($products)]);
    Response::success("Products retrieved", $products);
}

function getById($id) {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $product = new Product($db);
    
    $productData = $product->getById($id);
    
    if ($productData) {
        Response::success("Product retrieved", $productData);
    } else {
        Response::error("Product not found", 404);
    }
}

function getByCategory() {
    JWTAuth::verifyToken();
    
    $category = isset($_GET['category']) ? $_GET['category'] : null;
    
    if (!$category) {
        Response::error("Category is required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $product = new Product($db);
    
    $products = $product->getByCategory($category);
    
    Response::success("Products retrieved", $products);
}

function create() {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (!isset($data['name']) || !isset($data['category']) || !isset($data['price']) || !isset($data['unit'])) {
        Response::error("Name, category, price, and unit are required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $product = new Product($db);
    
    $product->name = $data['name'];
    $product->category = $data['category'];
    $product->price = $data['price'];
    $product->unit = $data['unit'];
    
    $product_id = $product->create();
    
    if ($product_id) {
        Logger::info("Product created", ['product_id' => $product_id, 'name' => $data['name']]);
        Response::success("Product created successfully", ['product_id' => $product_id], 201);
    } else {
        Logger::error("Failed to create product");
        Response::error("Failed to create product", 500);
    }
}

function update($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $product = new Product($db);
    
    $product->product_id = $id;
    $product->name = $data['name'];
    $product->category = $data['category'];
    $product->price = $data['price'];
    $product->unit = $data['unit'];
    
    if ($product->update()) {
        Logger::info("Product updated", ['product_id' => $id]);
        Response::success("Product updated successfully");
    } else {
        Logger::error("Failed to update product", ['product_id' => $id]);
        Response::error("Failed to update product", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $product = new Product($db);
    
    $product->product_id = $id;
    
    if ($product->delete()) {
        Logger::info("Product deleted", ['product_id' => $id]);
        Response::success("Product deleted successfully");
    } else {
        Logger::error("Failed to delete product", ['product_id' => $id]);
        Response::error("Failed to delete product", 500);
    }
}

// Handle product routes based on HTTP method
switch ($method) {
    case 'GET':
        if ($action === null) {
            // GET /products - get all products
            getAll();
        } elseif (is_numeric($action)) {
            // GET /products/{id} - get product by ID
            getById($action);
        } elseif ($action === 'category') {
            // GET /products/category?category=X - get by category
            getByCategory();
        } else {
            Response::error("Invalid action");
        }
        break;
        
    case 'POST':
        if ($action === null) {
            // POST /products - create new product
            create();
        } else {
            Response::error("Invalid action");
        }
        break;
        
    case 'PUT':
    case 'PATCH':
        if (is_numeric($action)) {
            // PUT /products/{id} - update product
            update($action);
        } else {
            Response::error("Product ID is required");
        }
        break;
        
    case 'DELETE':
        if (is_numeric($action)) {
            // DELETE /products/{id} - delete product
            delete($action);
        } else {
            Response::error("Product ID is required");
        }
        break;
        
    default:
        Response::error("Method not allowed", 405);
        break;
}
