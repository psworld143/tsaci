import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/admin/user_management_screen.dart';
import '../../screens/admin/product_management_screen.dart';
import '../../screens/admin/inventory_management_screen.dart';
import '../../screens/admin/sales_management_screen.dart';
import '../../screens/admin/expense_management_screen.dart';
import '../../screens/admin/system_config_screen.dart';
import '../../screens/admin/system_reports_screen.dart';
import '../../screens/manager/production_report_screen.dart';
import '../../screens/manager/sales_report_screen.dart';
import '../../screens/manager/expense_report_screen.dart';
import '../../screens/manager/inventory_report_screen.dart';
import '../../screens/admin/performance_report_screen.dart';
import '../../screens/supervisor/add_production_screen.dart';

/// Unified App Drawer/Sidebar
class AppDrawer extends StatefulWidget {
  final String userRole;

  const AppDrawer({Key? key, required this.userRole}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user.name;
        _userEmail = user.email;
        _userRole = user.role;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppStyles.space4,
              bottom: AppStyles.space4,
              left: AppStyles.space4,
              right: AppStyles.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(AppStyles.space3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                  ),
                  child: const Icon(
                    Icons.factory,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppStyles.space3),
                Text(
                  _userName,
                  style: AppStyles.headingSm.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppStyles.space1),
                Text(
                  _userEmail,
                  style: AppStyles.bodySm.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppStyles.space2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.space2,
                    vertical: AppStyles.space1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  ),
                  child: Text(
                    _userRole.toUpperCase(),
                    style: AppStyles.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppStyles.space2),
              children: _buildMenuItems(),
            ),
          ),

          // Footer
          const Divider(height: 1),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _handleLogout,
            color: AppColors.error,
          ),
          const SizedBox(height: AppStyles.space2),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    switch (widget.userRole.toLowerCase()) {
      case 'admin':
        return _buildAdminMenu();
      case 'production_manager':
        return _buildManagerMenu(); // Production-focused menu
      case 'inventory_officer':
        return _buildManagerMenu(); // Inventory-focused menu
      case 'qa_officer':
        return _buildManagerMenu(); // QA-focused menu
      case 'worker':
        return _buildSupervisorMenu(); // Production logging
      // DEPRECATED: Legacy roles
      case 'owner': // redirects to admin
        return _buildAdminMenu();
      case 'manager': // redirects to production_manager
        return _buildManagerMenu();
      case 'supervisor': // redirects to worker
        return _buildSupervisorMenu();
      default:
        return _buildManagerMenu();
    }
  }

  List<Widget> _buildAdminMenu() {
    return [
      _buildDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () => Navigator.pop(context),
      ),
      _buildSectionHeader('Management'),
      _buildDrawerItem(
        icon: Icons.people,
        title: 'Users',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.inventory_2,
        title: 'Products',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductManagementScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.warehouse,
        title: 'Inventory',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InventoryManagementScreen(),
            ),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.point_of_sale,
        title: 'Sales',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesManagementScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.receipt_long,
        title: 'Expenses',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseManagementScreen()),
          );
        },
      ),
      _buildSectionHeader('Analytics'),
      _buildDrawerItem(
        icon: Icons.analytics,
        title: 'All Reports',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SystemReportsScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.factory,
        title: 'Production Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductionReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.point_of_sale,
        title: 'Sales Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.receipt,
        title: 'Expense Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.warehouse,
        title: 'Inventory Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.speed,
        title: 'Performance Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PerformanceReportScreen()),
          );
        },
      ),
      _buildSectionHeader('System'),
      _buildDrawerItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SystemConfigScreen()),
          );
        },
      ),
    ];
  }

  List<Widget> _buildSupervisorMenu() {
    return [
      _buildDrawerItem(
        icon: Icons.home,
        title: 'Home',
        onTap: () => Navigator.pop(context),
      ),
      _buildSectionHeader('Production'),
      _buildDrawerItem(
        icon: Icons.add_circle,
        title: 'Add Production Log',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductionScreen()),
          );
        },
      ),
    ];
  }

  List<Widget> _buildManagerMenu() {
    return [
      _buildDrawerItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () => Navigator.pop(context),
      ),
      _buildSectionHeader('Reports'),
      _buildDrawerItem(
        icon: Icons.factory,
        title: 'Production Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductionReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.point_of_sale,
        title: 'Sales Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.receipt,
        title: 'Expense Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.warehouse,
        title: 'Inventory Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryReportScreen()),
          );
        },
      ),
      _buildDrawerItem(
        icon: Icons.speed,
        title: 'Performance Report',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PerformanceReportScreen()),
          );
        },
      ),
    ];
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.space4,
        AppStyles.space4,
        AppStyles.space4,
        AppStyles.space2,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppStyles.labelSm.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 24),
      title: Text(title, style: AppStyles.labelMd.copyWith(color: color)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space1,
      ),
    );
  }
}
