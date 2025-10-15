<?php
/**
 * Authentication Controller
 * Handles login, register, verify
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    Response::error("Database connection failed", 500);
}

$method = $_SERVER['REQUEST_METHOD'];
$uri = explode('/', trim($_GET['url'] ?? '', '/'));
$action = $uri[1] ?? '';

switch ($method) {
    case 'POST':
        if ($action === 'login') {
            login($db);
        } elseif ($action === 'register') {
            register($db);
        } else {
            Response::notFound("Action not found");
        }
        break;
    
    case 'GET':
        if ($action === 'verify') {
            verify();
        } elseif ($action === 'profile') {
            profile($db);
        } else {
            Response::notFound("Action not found");
        }
        break;
        
    default:
        Response::error("Method not allowed", 405);
}

/**
 * User Login
 */
function login($db) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['email']) || !isset($data['password'])) {
        Response::validationError(['email' => 'Email is required', 'password' => 'Password is required']);
    }

    $email = $data['email'];
    $password = $data['password'];

    $user = new User($db);
    $userData = $user->getByEmail($email);

    if (!$userData) {
        Logger::authAttempt($email, false);
        Response::error("Invalid email or password", 401);
    }

    if (!$user->verifyPassword($password, $userData['password_hash'])) {
        Logger::authAttempt($email, false);
        Response::error("Invalid email or password", 401);
    }

    $token = JWTAuth::generateToken($userData['user_id'], $userData['email'], $userData['role']);
    
    Logger::authAttempt($email, true);

    Response::success("Login successful", [
        'token' => $token,
        'user' => [
            'user_id' => $userData['user_id'],
            'name' => $userData['name'],
            'email' => $userData['email'],
            'role' => $userData['role']
        ]
    ]);
}

/**
 * User Registration
 */
function register($db) {
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['name']) || !isset($data['email']) || !isset($data['password'])) {
        Response::validationError([
            'name' => 'Name is required',
            'email' => 'Email is required',
            'password' => 'Password is required'
        ]);
    }

    $user = new User($db);
    $existing = $user->getByEmail($data['email']);
    
    if ($existing) {
        Logger::warning("Registration failed: Email already exists", ['email' => $data['email']]);
        Response::error("Email already exists", 400);
    }

    $user->name = $data['name'];
    $user->email = $data['email'];
    $user->password_hash = $data['password'];
    $user->role = $data['role'] ?? 'supervisor';

    $user_id = $user->create();

    if ($user_id) {
        $token = JWTAuth::generateToken($user_id, $data['email'], $user->role);
        
        Logger::info("User registered successfully", [
            'user_id' => $user_id,
            'email' => $data['email'],
            'role' => $user->role
        ]);

        Response::success("Registration successful", [
            'token' => $token,
            'user' => [
                'user_id' => $user_id,
                'name' => $data['name'],
                'email' => $data['email'],
                'role' => $user->role
            ]
        ], 201);
    } else {
        Logger::error("User registration failed", ['email' => $data['email']]);
        Response::error("Failed to register user", 500);
    }
}

/**
 * Verify Token
 */
function verify() {
    $user = JWTAuth::getCurrentUser();

    Response::success("Token is valid", [
        'user' => [
            'user_id' => $user->user_id,
            'email' => $user->email,
            'role' => $user->role
        ]
    ]);
}

/**
 * Get current user profile
 */
function profile($db) {
    $currentUser = JWTAuth::getCurrentUser();
    
    $user = new User($db);
    $userData = $user->getById($currentUser->user_id);

    if ($userData) {
        Response::success("Profile retrieved", $userData);
    } else {
        Response::notFound("User not found");
    }
}
