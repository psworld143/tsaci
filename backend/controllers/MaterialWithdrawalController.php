<?php
/**
 * Material Withdrawal Controller
 * Handles material withdrawal request API
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../api/MaterialWithdrawalController.php';
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
$withdrawalController = new MaterialWithdrawalController($db);

// Handle request based on method and action
switch ($method) {
    case 'GET':
        if ($action === null) {
            // GET /withdrawals - get all withdrawals
            $result = $withdrawalController->getAll();
            if ($result['success']) {
                Response::success('Withdrawals retrieved successfully', $result['data']);
            } else {
                Response::error($result['message']);
            }
        } else {
            Response::notFound('Action not found');
        }
        break;

    case 'POST':
        if ($action === null) {
            // POST /withdrawals - create new withdrawal
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (empty($data['inventory_id']) || empty($data['requested_quantity']) || empty($data['requested_by'])) {
                Response::badRequest('Missing required fields');
                exit;
            }
            
            $result = $withdrawalController->create($data);
            
            if ($result['success']) {
                Response::created($result, $result['message']);
            } else {
                Response::error($result['message']);
            }
        } elseif ($action === 'approve' && is_numeric($param)) {
            // POST /withdrawals/approve/{id} - approve withdrawal
            $data = json_decode(file_get_contents('php://input'), true);
            $approvedBy = $data['approved_by'] ?? $user->user_id;
            
            $result = $withdrawalController->approve($param, $approvedBy);
            
            if ($result['success']) {
                Response::success($result['message']);
            } else {
                Response::error($result['message']);
            }
        } elseif ($action === 'reject' && is_numeric($param)) {
            // POST /withdrawals/reject/{id} - reject withdrawal
            $data = json_decode(file_get_contents('php://input'), true);
            $approvedBy = $data['approved_by'] ?? $user->user_id;
            $reason = $data['reason'] ?? 'No reason provided';
            
            $result = $withdrawalController->reject($param, $approvedBy, $reason);
            
            if ($result['success']) {
                Response::success($result['message']);
            } else {
                Response::error($result['message']);
            }
        } else {
            Response::notFound('Action not found');
        }
        break;

    default:
        Response::error("Method $method not allowed", 405);
        break;
}

