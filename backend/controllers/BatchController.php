<?php
/**
 * Batch Controller
 * Handles production batch management API requests
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../api/ProductionBatchController.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';

// Verify authentication
$user = JWTAuth::verifyToken();

if (!$user) {
    Response::unauthorized('Authentication required');
    exit;
}

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

// Initialize controller
$batchController = new ProductionBatchController($db);

// Handle request based on method and action
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if ($action === null) {
            // Get all batches
            $result = $batchController->getAll();
            if ($result['success']) {
                Response::success('Batches retrieved successfully', $result['data']);
            } else {
                Response::error($result['message']);
            }
        } else {
            Response::notFound('Action not found');
        }
        break;

    case 'POST':
        if ($action === null) {
            // Create new batch
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (empty($data)) {
                Response::badRequest('No data provided');
                exit;
            }
            
            // Validate required fields
            if (empty($data['product_id']) || empty($data['target_quantity']) || empty($data['scheduled_date'])) {
                Response::badRequest('Missing required fields');
                exit;
            }
            
            $result = $batchController->create($data);
            
            if ($result['success']) {
                Response::created($result, $result['message']);
            } else {
                Response::error($result['message']);
            }
        } elseif ($action === 'stage' && $param) {
            // Update batch stage
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (empty($data['stage'])) {
                Response::badRequest('Stage is required');
                exit;
            }
            
            $result = $batchController->updateStage($param, $data['stage']);
            
            if ($result['success']) {
                Response::success(null, $result['message']);
            } else {
                Response::error($result['message']);
            }
        } elseif ($action === 'status' && $param) {
            // Update batch status
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (empty($data['status'])) {
                Response::badRequest('Status is required');
                exit;
            }
            
            $result = $batchController->updateStatus($param, $data['status']);
            
            if ($result['success']) {
                Response::success(null, $result['message']);
            } else {
                Response::error($result['message']);
            }
        } else {
            Response::notFound('Action not found');
        }
        break;

    case 'PUT':
        if ($action) {
            // Update batch
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (empty($data)) {
                Response::badRequest('No data provided');
                exit;
            }
            
            $result = $batchController->update($action, $data);
            
            if ($result['success']) {
                Response::success(null, $result['message']);
            } else {
                Response::error($result['message']);
            }
        } else {
            Response::badRequest('Batch ID is required');
        }
        break;

    case 'DELETE':
        if ($action) {
            // Delete batch
            $result = $batchController->delete($action);
            
            if ($result['success']) {
                Response::success(null, $result['message']);
            } else {
                Response::error($result['message']);
            }
        } else {
            Response::badRequest('Batch ID is required');
        }
        break;

    default:
        Response::methodNotAllowed("Method $method not allowed");
        break;
}

