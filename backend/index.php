<?php
/**
 * TSACI API Entry Point
 * Simple Router for REST API
 */

require_once __DIR__ . '/config/cors.php';
require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/helpers/response.php';
require_once __DIR__ . '/helpers/logger.php';

// Initialize CORS
CorsConfig::apply();

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

// Get request URI
$uri = $_GET['url'] ?? '';
$uri = trim($uri, '/');
$uriParts = explode('/', $uri);

// Get the endpoint/module
$endpoint = $uriParts[0] ?? 'index';
$action = $uriParts[1] ?? null;
$param = $uriParts[2] ?? null;

// Map endpoints to their controller files
$routes = [
    'auth' => 'controllers/AuthController.php',
    'users' => 'controllers/UserController.php',
    'config' => 'controllers/ConfigController.php',
    'production' => 'controllers/ProductionController.php',
    'inventory' => 'controllers/InventoryController.php',
    'sales' => 'controllers/SalesController.php',
    'expenses' => 'controllers/ExpenseController.php',
    'reports' => 'controllers/ReportController.php',
    'products' => 'controllers/ProductController.php',
    'customers' => 'controllers/CustomerController.php',
    'suppliers' => 'controllers/SupplierController.php',
    'batches' => 'controllers/BatchController.php',
    'withdrawals' => 'controllers/MaterialWithdrawalController.php'
];

// Route to appropriate controller
if ($endpoint === '' || $endpoint === 'index') {
    Response::success([
        'name' => 'TSACI Plant Monitoring System API',
        'version' => '1.0.0',
        'status' => 'running'
    ], 'API is running');
} elseif (isset($routes[$endpoint])) {
    $controllerFile = __DIR__ . '/' . $routes[$endpoint];
    
    if (file_exists($controllerFile)) {
        // Log the API request
        Logger::apiRequest($method, $uri, []);
        
        require_once $controllerFile;
    } else {
        Response::notFound("Endpoint not found");
    }
} else {
    Response::notFound("Invalid endpoint");
}
