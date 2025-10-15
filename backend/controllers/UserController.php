<?php
/**
 * User Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function getAll() {
    JWTAuth::requireRole(['admin', 'owner', 'production_manager']);
    
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    
    $users = $user->getAll();
    
    Logger::info("Users retrieved", ['count' => count($users)]);
    Response::success("Users retrieved", $users);
}

function getById($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    
    $userData = $user->getById($id);
    
    if ($userData) {
        // Remove password from response
        unset($userData['password']);
        Response::success("User retrieved", $userData);
    } else {
        Response::error("User not found", 404);
    }
}

function create() {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (!isset($data['name']) || !isset($data['email']) || !isset($data['password']) || !isset($data['role'])) {
        Response::error("Name, email, password, and role are required");
        return;
    }
    
    // Validate role
    $validRoles = ['admin', 'manager', 'supervisor', 'viewer'];
    if (!in_array($data['role'], $validRoles)) {
        Response::error("Invalid role. Must be one of: " . implode(', ', $validRoles));
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    
    // Check if email already exists
    if ($user->emailExists($data['email'])) {
        Response::error("Email already exists", 409);
        return;
    }
    
    $user->name = $data['name'];
    $user->email = $data['email'];
    $user->password = password_hash($data['password'], PASSWORD_DEFAULT);
    $user->role = $data['role'];
    
    $user_id = $user->create();
    
    if ($user_id) {
        Logger::info("User created", ['user_id' => $user_id, 'email' => $data['email'], 'role' => $data['role']]);
        Response::success("User created successfully", [
            'user_id' => $user_id,
            'name' => $data['name'],
            'email' => $data['email'],
            'role' => $data['role']
        ], 201);
    } else {
        Logger::error("Failed to create user", ['email' => $data['email']]);
        Response::error("Failed to create user", 500);
    }
}

function update($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    
    // Validate role if provided
    if (isset($data['role'])) {
        $validRoles = ['admin', 'manager', 'supervisor', 'viewer'];
        if (!in_array($data['role'], $validRoles)) {
            Response::error("Invalid role. Must be one of: " . implode(', ', $validRoles));
            return;
        }
    }
    
    $user->user_id = $id;
    $user->name = $data['name'];
    $user->email = $data['email'];
    $user->role = $data['role'];
    
    // Only update password if provided
    if (isset($data['password']) && !empty($data['password'])) {
        $user->password = password_hash($data['password'], PASSWORD_DEFAULT);
    }
    
    if ($user->update()) {
        Logger::info("User updated", ['user_id' => $id, 'email' => $data['email']]);
        Response::success("User updated successfully");
    } else {
        Logger::error("Failed to update user", ['user_id' => $id]);
        Response::error("Failed to update user", 500);
    }
}

function updateRole($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['role'])) {
        Response::error("Role is required");
        return;
    }
    
    // Validate role
    $validRoles = ['admin', 'manager', 'supervisor', 'viewer'];
    if (!in_array($data['role'], $validRoles)) {
        Response::error("Invalid role. Must be one of: " . implode(', ', $validRoles));
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    
    if ($user->updateRole($id, $data['role'])) {
        Logger::info("User role updated", ['user_id' => $id, 'role' => $data['role']]);
        Response::success("User role updated successfully");
    } else {
        Logger::error("Failed to update user role", ['user_id' => $id]);
        Response::error("Failed to update user role", 500);
    }
}

function resetPassword($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['new_password'])) {
        Response::error("New password is required");
        return;
    }
    
    if (strlen($data['new_password']) < 6) {
        Response::error("Password must be at least 6 characters long");
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    
    $hashedPassword = password_hash($data['new_password'], PASSWORD_DEFAULT);
    
    if ($user->resetPassword($id, $hashedPassword)) {
        Logger::info("User password reset", ['user_id' => $id]);
        Response::success("Password reset successfully");
    } else {
        Logger::error("Failed to reset user password", ['user_id' => $id]);
        Response::error("Failed to reset password", 500);
    }
}

function delete($id) {
    JWTAuth::requireRole(['admin', 'owner']);
    $currentUser = JWTAuth::verifyToken();
    
    // Prevent self-deletion
    if ($currentUser->user_id == $id) {
        Response::error("You cannot delete your own account", 403);
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $user = new User($db);
    
    $user->user_id = $id;
    
    if ($user->delete()) {
        Logger::info("User deleted", ['user_id' => $id]);
        Response::success("User deleted successfully");
    } else {
        Logger::error("Failed to delete user", ['user_id' => $id]);
        Response::error("Failed to delete user", 500);
    }
}

// Handle user routes based on HTTP method
switch ($method) {
    case 'GET':
        if ($action === null) {
            // GET /users - get all users
            getAll();
        } elseif (is_numeric($action)) {
            // GET /users/{id} - get user by ID
            getById($action);
        } else {
            Response::error("Invalid action");
        }
        break;
        
    case 'POST':
        if ($action === null) {
            // POST /users - create new user
            create();
        } elseif ($action === 'reset-password' && is_numeric($param)) {
            // POST /users/reset-password/{id} - reset password
            resetPassword($param);
        } else {
            Response::error("Invalid action");
        }
        break;
        
    case 'PUT':
    case 'PATCH':
        if (is_numeric($action)) {
            // PUT /users/{id} - update user
            update($action);
        } elseif ($action === 'role' && is_numeric($param)) {
            // PUT /users/role/{id} - update role
            updateRole($param);
        } else {
            Response::error("User ID is required");
        }
        break;
        
    case 'DELETE':
        if (is_numeric($action)) {
            // DELETE /users/{id} - delete user
            delete($action);
        } else {
            Response::error("User ID is required");
        }
        break;
        
    default:
        Response::error("Method not allowed", 405);
        break;
}

