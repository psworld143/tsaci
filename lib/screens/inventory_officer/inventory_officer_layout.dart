import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import 'inventory_officer_home_screen.dart';
import 'stock_management_screen.dart';
import 'stock_adjustment_screen.dart';
import 'material_tracking_screen.dart';
import 'reorder_management_screen.dart';
import '../manager/production_report_screen.dart';
import '../manager/sales_report_screen.dart';
import '../manager/expense_report_screen.dart';
import '../manager/inventory_report_screen.dart';

/// Inventory Officer Layout with Navigation
class InventoryOfficerLayout extends StatefulWidget {
  final String? initialRoute;

  const InventoryOfficerLayout({Key? key, this.initialRoute}) : super(key: key);

  @override
  State<InventoryOfficerLayout> createState() => _InventoryOfficerLayoutState();
}

class _InventoryOfficerLayoutState extends State<InventoryOfficerLayout> {
  String _userName = '';
  String _userEmail = '';
  String _currentRoute = '/inventory/dashboard';
  final List<String> _navigationHistory = ['/inventory/dashboard'];

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute ?? '/inventory/dashboard';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user.name;
        _userEmail = user.email;
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

  void _navigateTo(String route) {
    setState(() {
      if (_currentRoute != route) {
        _navigationHistory.add(_currentRoute);
      }
      _currentRoute = route;
    });
  }

  Widget _getCurrentScreen() {
    switch (_currentRoute) {
      case '/inventory/dashboard':
        return const InventoryOfficerHomeScreen();
      case '/inventory/stock':
        return const StockManagementScreen();
      case '/inventory/adjustments':
        return const StockAdjustmentScreen();
      case '/inventory/materials':
        return const MaterialTrackingScreen();
      case '/inventory/reorders':
        return const ReorderManagementScreen();
      case '/inventory/reports/production':
        return const ProductionReportScreen();
      case '/inventory/reports/sales':
        return const SalesReportScreen();
      case '/inventory/reports/expenses':
        return const ExpenseReportScreen();
      case '/inventory/reports/inventory':
        return const InventoryReportScreen();
      default:
        return const InventoryOfficerHomeScreen();
    }
  }

  String _getCurrentTitle() {
    switch (_currentRoute) {
      case '/inventory/dashboard':
        return 'Inventory Dashboard';
      case '/inventory/stock':
        return 'Stock Management';
      case '/inventory/adjustments':
        return 'Stock Adjustments';
      case '/inventory/materials':
        return 'Material Tracking';
      case '/inventory/reorders':
        return 'Reorder Management';
      case '/inventory/reports/production':
        return 'Production Report';
      case '/inventory/reports/sales':
        return 'Sales Report';
      case '/inventory/reports/expenses':
        return 'Expense Report';
      case '/inventory/reports/inventory':
        return 'Inventory Report';
      default:
        return 'Inventory Officer';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Desktop/Web layout with persistent sidebar
    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: _buildSidebar(),
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _getCurrentScreen()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout with drawer
    return Scaffold(
      appBar: AppBar(
        title: Text(_getCurrentTitle()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(child: _buildSidebar()),
      body: _getCurrentScreen(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.space6,
        vertical: AppStyles.space4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          Text(_getCurrentTitle(), style: AppStyles.headingLg),
          const Spacer(),
          Text(
            _userName,
            style: AppStyles.labelMd.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Profile Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + AppStyles.space4,
            bottom: AppStyles.space4,
            left: AppStyles.space4,
            right: AppStyles.space4,
          ),
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: const Icon(
                  Icons.warehouse,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppStyles.space3),
              Text(
                _userName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _userEmail,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
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
                  'INVENTORY OFFICER',
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
            children: [
              _buildMenuItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                route: '/inventory/dashboard',
                onTap: () => _navigateTo('/inventory/dashboard'),
              ),
              _buildSectionHeader('Inventory Management'),
              _buildMenuItem(
                icon: Icons.warehouse,
                title: 'Stock Management',
                subtitle: 'View & update stock',
                route: '/inventory/stock',
                onTap: () => _navigateTo('/inventory/stock'),
              ),
              _buildMenuItem(
                icon: Icons.move_up,
                title: 'Stock Adjustments',
                subtitle: 'In/Out/Waste tracking',
                route: '/inventory/adjustments',
                onTap: () => _navigateTo('/inventory/adjustments'),
              ),
              _buildMenuItem(
                icon: Icons.sync_alt,
                title: 'Material Tracking',
                subtitle: 'Withdrawal requests',
                route: '/inventory/materials',
                onTap: () => _navigateTo('/inventory/materials'),
              ),
              _buildMenuItem(
                icon: Icons.shopping_cart,
                title: 'Reorder Management',
                subtitle: 'Low stock & procurement',
                route: '/inventory/reorders',
                onTap: () => _navigateTo('/inventory/reorders'),
              ),
              _buildSectionHeader('Reports'),
              _buildMenuItem(
                icon: Icons.warehouse,
                title: 'Inventory Report',
                route: '/inventory/reports/inventory',
                onTap: () => _navigateTo('/inventory/reports/inventory'),
              ),
              _buildMenuItem(
                icon: Icons.factory,
                title: 'Production Report',
                route: '/inventory/reports/production',
                onTap: () => _navigateTo('/inventory/reports/production'),
              ),
              _buildMenuItem(
                icon: Icons.point_of_sale,
                title: 'Sales Report',
                route: '/inventory/reports/sales',
                onTap: () => _navigateTo('/inventory/reports/sales'),
              ),
              _buildMenuItem(
                icon: Icons.receipt,
                title: 'Expense Report',
                route: '/inventory/reports/expenses',
                onTap: () => _navigateTo('/inventory/reports/expenses'),
              ),
            ],
          ),
        ),

        // Logout
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Logout'),
          onTap: _handleLogout,
        ),
        const SizedBox(height: AppStyles.space2),
      ],
    );
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required String route,
    required VoidCallback onTap,
  }) {
    final isActive = _currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppStyles.space2,
        vertical: AppStyles.space1,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: AppStyles.labelMd.copyWith(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppStyles.bodyXs.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
        ),
      ),
    );
  }
}
