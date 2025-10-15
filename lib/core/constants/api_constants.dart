/// API Configuration
class ApiConstants {
  // Base URL - Direct to backend router (index.php handles routing)
  // Works with iOS, Android, macOS, Windows, Linux, Chrome
  static const String baseUrl = 'http://localhost/tsaci/backend';

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get verify => '$baseUrl/auth/verify';
  static String get profile => '$baseUrl/auth/profile';

  // User Management Endpoints
  static String get users => '$baseUrl/users';
  static String userById(int id) => '$baseUrl/users/$id';

  // Production Endpoints
  static String get production => '$baseUrl/production';
  static String productionById(int id) => '$baseUrl/production/$id';
  static String get productionFilterDate => '$baseUrl/production/filter/date';
  static String get productionFilterProduct =>
      '$baseUrl/production/filter/product';

  // Inventory Endpoints
  static String get inventory => '$baseUrl/inventory';
  static String inventoryByProduct(int id) => '$baseUrl/inventory/product/$id';
  static String get inventoryLowStock => '$baseUrl/inventory/low-stock';

  // Sales Endpoints
  static String get sales => '$baseUrl/sales';
  static String salesById(int id) => '$baseUrl/sales/$id';
  static String get salesFilterDate => '$baseUrl/sales/filter/date';

  // Expenses Endpoints
  static String get expenses => '$baseUrl/expenses';
  static String expensesById(int id) => '$baseUrl/expenses/$id';
  static String get expensesFilterDate => '$baseUrl/expenses/filter/date';
  static String get expensesFilterCategory =>
      '$baseUrl/expenses/filter/category';

  // Reports Endpoints
  static String get reportsMonthly => '$baseUrl/reports/monthly';
  static String get reportsDashboard => '$baseUrl/reports/dashboard';
  static String get reportsProductionSummary =>
      '$baseUrl/reports/production-summary';

  // Products Endpoints
  static String get products => '$baseUrl/products';
  static String productsById(int id) => '$baseUrl/products/$id';

  // Customers Endpoints
  static String get customers => '$baseUrl/customers';

  // Suppliers Endpoints
  static String get suppliers => '$baseUrl/suppliers';

  // Batch Endpoints
  static String get batches => '$baseUrl/batches';
  static String batchById(int id) => '$baseUrl/batches/$id';
  static String batchStage(int id) => '$baseUrl/batches/stage/$id';
  static String batchStatus(int id) => '$baseUrl/batches/status/$id';

  // Material Withdrawal Endpoints
  static String get withdrawals => '$baseUrl/withdrawals';
  static String withdrawalById(int id) => '$baseUrl/withdrawals/$id';
  static String withdrawalApprove(int id) => '$baseUrl/withdrawals/approve/$id';
  static String withdrawalReject(int id) => '$baseUrl/withdrawals/reject/$id';
}
