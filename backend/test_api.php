<?php
/**
 * API Test Script
 * Simple script to test if the API is working correctly
 */

echo "=== TSACI API Test Script ===\n\n";

// Test 1: Check if database connection works
echo "1. Testing Database Connection...\n";
require_once __DIR__ . '/config/db.php';
$database = new Database();
$db = $database->getConnection();

if ($db) {
    echo "   ✓ Database connection successful!\n\n";
} else {
    echo "   ✗ Database connection failed!\n\n";
    exit(1);
}

// Test 2: Check if tables exist
echo "2. Checking Database Tables...\n";
$tables = ['users', 'products', 'production', 'inventory', 'sales', 'expenses', 'suppliers', 'customers'];
foreach ($tables as $table) {
    $query = "SHOW TABLES LIKE '$table'";
    $stmt = $db->prepare($query);
    $stmt->execute();
    if ($stmt->rowCount() > 0) {
        echo "   ✓ Table '$table' exists\n";
    } else {
        echo "   ✗ Table '$table' does not exist\n";
    }
}

echo "\n3. Checking Default Data...\n";
// Check if default admin user exists
$query = "SELECT * FROM users WHERE email = 'admin@tsaci.com' LIMIT 1";
$stmt = $db->prepare($query);
$stmt->execute();
if ($stmt->rowCount() > 0) {
    echo "   ✓ Default admin user exists\n";
} else {
    echo "   ✗ Default admin user not found\n";
}

// Check if products exist
$query = "SELECT COUNT(*) as count FROM products";
$stmt = $db->prepare($query);
$stmt->execute();
$result = $stmt->fetch();
echo "   ✓ Products in database: " . $result['count'] . "\n";

echo "\n4. Testing JWT Token Generation...\n";
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/middleware/jwt_auth.php';

try {
    $token = JWTAuth::generateToken(1, 'test@tsaci.com', 'admin');
    echo "   ✓ JWT token generated successfully\n";
    echo "   Token: " . substr($token, 0, 50) . "...\n";
} catch (Exception $e) {
    echo "   ✗ JWT token generation failed: " . $e->getMessage() . "\n";
}

echo "\n5. API Endpoints Summary:\n";
echo "   Base URL: http://localhost/tsaci/backend/api\n";
echo "   - POST /auth/login\n";
echo "   - POST /auth/register\n";
echo "   - GET  /auth/verify\n";
echo "   - GET  /production\n";
echo "   - POST /production\n";
echo "   - GET  /inventory\n";
echo "   - GET  /sales\n";
echo "   - GET  /expenses\n";
echo "   - GET  /reports/monthly\n";
echo "   - GET  /reports/dashboard\n";

echo "\n=== Test Complete ===\n";
echo "\nTo test the API:\n";
echo "1. Make sure Apache and MySQL are running\n";
echo "2. Import the database schema from backend/database/schema.sql\n";
echo "3. Use curl or Postman to test endpoints\n";
echo "\nExample login:\n";
echo "curl -X POST http://localhost/tsaci/backend/api/auth/login \\\n";
echo "  -H 'Content-Type: application/json' \\\n";
echo "  -d '{\"email\":\"admin@tsaci.com\",\"password\":\"admin123\"}'\n";

