<?php
/**
 * System Config Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/SystemConfig.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $config = new SystemConfig($db);
    
    $configs = $config->getAll();
    
    // Parse JSON values
    $formatted = [];
    foreach ($configs as $item) {
        if ($item['config_type'] === 'json') {
            $item['config_value'] = json_decode($item['config_value'], true);
        }
        $formatted[] = $item;
    }
    
    Logger::info("System configs retrieved", ['count' => count($formatted)]);
    Response::success("System configurations retrieved", $formatted);
}

function getByKey($key) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $config = new SystemConfig($db);
    
    $configData = $config->getByKey($key);
    
    if ($configData) {
        if ($configData['config_type'] === 'json') {
            $configData['config_value'] = json_decode($configData['config_value'], true);
        }
        Response::success("Configuration retrieved", $configData);
    } else {
        Response::error("Configuration not found", 404);
    }
}

function update() {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['config_key']) || !isset($data['config_value'])) {
        Response::error("Config key and value are required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $config = new SystemConfig($db);
    
    $key = $data['config_key'];
    $value = $data['config_value'];
    $type = isset($data['config_type']) ? $data['config_type'] : 'text';
    $description = isset($data['description']) ? $data['description'] : null;
    
    // If value is array, convert to JSON
    if (is_array($value)) {
        $value = json_encode($value);
        $type = 'json';
    }
    
    if ($config->upsert($key, $value, $type, $description)) {
        Logger::info("System config updated", ['key' => $key]);
        Response::success("Configuration updated successfully");
    } else {
        Logger::error("Failed to update system config", ['key' => $key]);
        Response::error("Failed to update configuration", 500);
    }
}

function updateBulk() {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['configs']) || !is_array($data['configs'])) {
        Response::error("Configs array is required");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $config = new SystemConfig($db);
    
    $updated = 0;
    foreach ($data['configs'] as $item) {
        if (!isset($item['config_key']) || !isset($item['config_value'])) {
            continue;
        }
        
        $key = $item['config_key'];
        $value = $item['config_value'];
        $type = isset($item['config_type']) ? $item['config_type'] : 'text';
        $description = isset($item['description']) ? $item['description'] : null;
        
        // If value is array, convert to JSON
        if (is_array($value)) {
            $value = json_encode($value);
            $type = 'json';
        }
        
        if ($config->upsert($key, $value, $type, $description)) {
            $updated++;
        }
    }
    
    Logger::info("Bulk system config updated", ['count' => $updated]);
    Response::success("$updated configurations updated successfully");
}

function delete($key) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $config = new SystemConfig($db);
    
    if ($config->delete($key)) {
        Logger::info("System config deleted", ['key' => $key]);
        Response::success("Configuration deleted successfully");
    } else {
        Logger::error("Failed to delete system config", ['key' => $key]);
        Response::error("Failed to delete configuration", 500);
    }
}

// Handle config routes
if (isset($action)) {
    switch ($action) {
        case 'getAll':
            getAll();
            break;
        case 'getByKey':
            if (isset($param)) getByKey($param);
            else Response::error("Config key is required");
            break;
        case 'update':
            update();
            break;
        case 'updateBulk':
            updateBulk();
            break;
        case 'delete':
            if (isset($param)) delete($param);
            else Response::error("Config key is required");
            break;
        default:
            Response::error("Invalid action");
    }
}

