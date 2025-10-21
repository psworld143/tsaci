import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration
class ApiConstants {
  // Base URL - Platform-aware configuration
  // Automatically detects the platform and uses the correct URL
  static String get baseUrl {
    // For web builds
    if (kIsWeb) {
      return 'http://localhost/tsaci/backend';
    }

    // For mobile and desktop platforms
    if (!kIsWeb) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      if (Platform.isAndroid) {
        return 'http://10.0.2.2/tsaci/backend';
      }

      // iOS simulator, macOS, Windows, Linux can use localhost
      // For real devices, set your machine's IP in environment or use localhost for desktop
      if (Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isWindows ||
          Platform.isLinux) {
        // Option 1: Use localhost for desktop and iOS simulator
        return 'http://localhost/tsaci/backend';

        // Option 2: For real iOS/Android devices, uncomment and set your machine's IP:
        // return 'http://192.168.1.XXX/tsaci/backend';  // Replace XXX with your IP
      }
    }

    // Fallback
    return 'http://localhost/tsaci/backend';
  }

  // Alternative: Environment-based configuration
  // Uncomment to use custom URL from environment
  // static String get baseUrl => const String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'http://localhost/tsaci/backend',
  // );

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
