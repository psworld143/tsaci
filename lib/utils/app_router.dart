import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/manager/manager_home_screen.dart';
import '../screens/supervisor/supervisor_home_screen.dart';
import '../core/widgets/admin_layout.dart';
import '../screens/production_manager/production_manager_layout.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// App Router - handles navigation and auth state
class AppRouter {
  static Future<Widget> getInitialScreen() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      // Get user role and redirect accordingly
      final role = await StorageService.getUserRole();

      switch (role?.toLowerCase() ?? '') {
        case 'admin':
          return const AdminLayout(initialRoute: '/admin/dashboard');
        case 'production_manager':
          return const ProductionManagerLayout(
            initialRoute: '/production/dashboard',
          );
        case 'inventory_officer':
          return const ManagerHomeScreen(); // Access to inventory reports
        case 'qa_officer':
          return const ManagerHomeScreen(); // Access to QA reports
        case 'worker':
          return const SupervisorHomeScreen(); // Production logging
        // DEPRECATED: Legacy roles (for backward compatibility only)
        // These redirect to new role equivalents
        case 'manager': // DEPRECATED: Use 'production_manager' instead
          return const ProductionManagerLayout(
            initialRoute: '/production/dashboard',
          );
        case 'owner': // DEPRECATED: Use 'admin' instead
          return const AdminLayout(initialRoute: '/admin/dashboard');
        case 'supervisor': // DEPRECATED: Use 'worker' instead
          return const SupervisorHomeScreen();
        default:
          return const LoginScreen();
      }
    }
    return const LoginScreen();
  }
}
