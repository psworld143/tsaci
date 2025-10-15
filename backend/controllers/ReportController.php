<?php
/**
 * Report Controller - Procedural Style
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/Production.php';
require_once __DIR__ . '/../models/Sale.php';
require_once __DIR__ . '/../models/Expense.php';
require_once __DIR__ . '/../models/Inventory.php';
require_once __DIR__ . '/../models/Product.php';
require_once __DIR__ . '/../middleware/jwt_auth.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/logger.php';

function dashboard() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    $sale = new Sale($db);
    $expense = new Expense($db);
    $inventory = new Inventory($db);
    
    $today = date('Y-m-d');
    $month_start = date('Y-m-01');
    $month_end = date('Y-m-t');
    
    // Today's production
    $today_production = $production->getByDateRange($today, $today);
    
    // Monthly totals
    $monthly_sales = $sale->getTotalSales($month_start, $month_end);
    $monthly_expenses = $expense->getTotalExpenses($month_start, $month_end);
    $monthly_income = $monthly_sales - $monthly_expenses;
    
    // Get top selling product
    $query = "SELECT p.name, SUM(s.quantity) as total_qty, SUM(s.total_amount) as total_sales 
              FROM sales s 
              LEFT JOIN products p ON s.product_id = p.product_id 
              WHERE s.date BETWEEN :start_date AND :end_date 
              AND s.status = 'completed'
              GROUP BY s.product_id 
              ORDER BY total_sales DESC 
              LIMIT 1";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':start_date', $month_start);
    $stmt->bindParam(':end_date', $month_end);
    $stmt->execute();
    $top_product = $stmt->fetch();
    
    // Low stock alerts
    $low_stock_count = count($inventory->getLowStock());
    
    // Total production batches
    $all_production = $production->getAll(1000);
    $total_batches = count($all_production);
    
    // Total products/materials
    $product = new Product($db);
    $all_products = $product->getAll();
    $total_materials = count($all_products);
    
    // Get all users count
    $user_query = "SELECT COUNT(*) as count FROM users";
    $user_stmt = $db->prepare($user_query);
    $user_stmt->execute();
    $user_result = $user_stmt->fetch();
    $active_users = $user_result['count'];
    
    Logger::info("Dashboard data retrieved");
    
    Response::success("Dashboard data retrieved", [
        'today' => [
            'date' => $today,
            'production_logs' => count($today_production)
        ],
        'monthly' => [
            'total_sales' => floatval($monthly_sales),
            'total_expenses' => floatval($monthly_expenses),
            'net_income' => floatval($monthly_income)
        ],
        'kpis' => [
            'total_batches' => $total_batches,
            'total_materials' => $total_materials,
            'low_stock_alerts' => $low_stock_count,
            'active_users' => intval($active_users)
        ],
        'top_product' => $top_product ? [
            'name' => $top_product['name'],
            'quantity_sold' => floatval($top_product['total_qty']),
            'total_sales' => floatval($top_product['total_sales'])
        ] : null,
        'alerts' => [
            'low_stock_count' => $low_stock_count
        ]
    ]);
}

function monthly() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    $sale = new Sale($db);
    $expense = new Expense($db);
    $inventory = new Inventory($db);
    
    $month = isset($_GET['month']) ? $_GET['month'] : date('m');
    $year = isset($_GET['year']) ? $_GET['year'] : date('Y');
    
    $start_date = "$year-$month-01";
    $end_date = date("Y-m-t", strtotime($start_date));
    
    // Get production data
    $production_logs = $production->getByDateRange($start_date, $end_date);
    
    // Calculate total production by product
    $production_by_product = [];
    foreach ($production_logs as $log) {
        $product_name = $log['product_name'];
        if (!isset($production_by_product[$product_name])) {
            $production_by_product[$product_name] = 0;
        }
        $production_by_product[$product_name] += $log['output_qty'];
    }
    
    // Get sales data
    $total_sales = $sale->getTotalSales($start_date, $end_date);
    
    // Get expenses data
    $total_expenses = $expense->getTotalExpenses($start_date, $end_date);
    $expenses_by_category = $expense->getExpensesByCategory($start_date, $end_date);
    
    // Calculate net income
    $net_income = $total_sales - $total_expenses;
    
    // Get current stock levels
    $stock_levels = $inventory->getAll();
    
    // Get low stock alerts
    $low_stock_items = $inventory->getLowStock();
    
    Response::success("Monthly report retrieved", [
        'period' => [
            'month' => $month,
            'year' => $year,
            'start_date' => $start_date,
            'end_date' => $end_date
        ],
        'production' => [
            'total_logs' => count($production_logs),
            'by_product' => $production_by_product
        ],
        'sales' => [
            'total_amount' => floatval($total_sales)
        ],
        'expenses' => [
            'total_amount' => floatval($total_expenses),
            'by_category' => $expenses_by_category
        ],
        'income' => [
            'net_income' => floatval($net_income),
            'profit_margin' => $total_sales > 0 ? round(($net_income / $total_sales) * 100, 2) : 0
        ],
        'inventory' => [
            'stock_levels' => $stock_levels,
            'low_stock_count' => count($low_stock_items),
            'low_stock_items' => $low_stock_items
        ]
    ]);
}

function productionSummary() {
    JWTAuth::verifyToken();
    
    $database = new Database();
    $db = $database->getConnection();
    $production = new Production($db);
    
    $start_date = isset($_GET['start_date']) ? $_GET['start_date'] : date('Y-m-01');
    $end_date = isset($_GET['end_date']) ? $_GET['end_date'] : date('Y-m-t');
    
    $production_logs = $production->getByDateRange($start_date, $end_date);
    
    // Summary by product
    $summary = [];
    foreach ($production_logs as $log) {
        $product_id = $log['product_id'];
        if (!isset($summary[$product_id])) {
            $summary[$product_id] = [
                'product_name' => $log['product_name'],
                'total_input' => 0,
                'total_output' => 0,
                'efficiency' => 0,
                'logs_count' => 0
            ];
        }
        $summary[$product_id]['total_input'] += $log['input_qty'];
        $summary[$product_id]['total_output'] += $log['output_qty'];
        $summary[$product_id]['logs_count']++;
    }
    
    // Calculate efficiency
    foreach ($summary as $product_id => $data) {
        if ($data['total_input'] > 0) {
            $summary[$product_id]['efficiency'] = round(($data['total_output'] / $data['total_input']) * 100, 2);
        }
    }
    
    Response::success("Production summary retrieved", [
        'period' => [
            'start_date' => $start_date,
            'end_date' => $end_date
        ],
        'summary' => array_values($summary)
    ]);
}

// Handle report routes
if (isset($action)) {
    switch ($action) {
        case 'dashboard':
            dashboard();
            break;
        case 'monthly':
            monthly();
            break;
        case 'productionSummary':
            productionSummary();
            break;
        default:
            Response::error("Invalid action");
    }
}
