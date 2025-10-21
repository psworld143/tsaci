<?php
/**
 * Audit Log Controller
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../helpers/audit_logger.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';

function getAll() {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $auditLogger = new AuditLogger($db);
    
    $filters = [];
    
    // Apply filters from query params
    if (isset($_GET['user_id'])) {
        $filters['user_id'] = $_GET['user_id'];
    }
    
    if (isset($_GET['entity_type'])) {
        $filters['entity_type'] = $_GET['entity_type'];
    }
    
    if (isset($_GET['action'])) {
        $filters['action'] = $_GET['action'];
    }
    
    if (isset($_GET['start_date'])) {
        $filters['start_date'] = $_GET['start_date'];
    }
    
    if (isset($_GET['end_date'])) {
        $filters['end_date'] = $_GET['end_date'];
    }
    
    if (isset($_GET['limit'])) {
        $filters['limit'] = intval($_GET['limit']);
    } else {
        $filters['limit'] = 100;
    }
    
    $logs = $auditLogger->getLogs($filters);
    
    Response::success("Audit logs retrieved", $logs);
}

function getStats() {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $auditLogger = new AuditLogger($db);
    
    $startDate = $_GET['start_date'] ?? null;
    $endDate = $_GET['end_date'] ?? null;
    
    $stats = $auditLogger->getStats($startDate, $endDate);
    
    Response::success("Audit statistics retrieved", $stats);
}

// Handle audit log routes
switch ($method) {
    case 'GET':
        if ($action === null) {
            // GET /audit-logs - get all logs
            getAll();
        } elseif ($action === 'stats') {
            // GET /audit-logs/stats - get statistics
            getStats();
        } else {
            Response::error("Invalid action");
        }
        break;
        
    default:
        Response::error("Method not allowed", 405);
        break;
}

