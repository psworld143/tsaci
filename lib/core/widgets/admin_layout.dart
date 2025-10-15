import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'widgets.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/admin/admin_home_screen.dart';
import '../../screens/admin/user_management_screen.dart';
import '../../screens/admin/product_management_screen.dart';
import '../../screens/admin/inventory_management_screen.dart';
import '../../screens/admin/sales_management_screen.dart';
import '../../screens/admin/expense_management_screen.dart';
import '../../screens/admin/system_config_screen.dart';
import '../../screens/admin/system_reports_screen.dart';
import '../../screens/admin/performance_report_screen.dart';
import '../../screens/manager/production_report_screen.dart';
import '../../screens/manager/sales_report_screen.dart';
import '../../screens/manager/expense_report_screen.dart';
import '../../screens/manager/inventory_report_screen.dart';

/// Admin Layout with Persistent Sidebar for Web
class AdminLayout extends StatefulWidget {
  final String? initialRoute;
  final VoidCallback? onAddUser;
  final VoidCallback? onAddProduct;
  final VoidCallback? onAddInventory;
  final VoidCallback? onAddSale;
  final VoidCallback? onAddExpense;

  const AdminLayout({
    Key? key,
    this.initialRoute,
    this.onAddUser,
    this.onAddProduct,
    this.onAddInventory,
    this.onAddSale,
    this.onAddExpense,
  }) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  String _userName = '';
  String _userEmail = '';
  String _currentRoute = '/admin/dashboard';
  final List<String> _navigationHistory = ['/admin/dashboard'];

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute ?? '/admin/dashboard';
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
    if (_currentRoute != route) {
      setState(() {
        _navigationHistory.add(_currentRoute);
        _currentRoute = route;
      });
    }
  }

  void _navigateBack() {
    if (_navigationHistory.isNotEmpty) {
      setState(() {
        _currentRoute = _navigationHistory.removeLast();
      });
    }
  }

  bool get _canGoBack => _navigationHistory.isNotEmpty;

  Widget _getCurrentScreen() {
    switch (_currentRoute) {
      case '/admin/dashboard':
        return const AdminHomeScreen();
      case '/admin/users':
        return const UserManagementScreen();
      case '/admin/products':
        return const ProductManagementScreen();
      case '/admin/inventory':
        return const InventoryManagementScreen();
      case '/admin/sales':
        return const SalesManagementScreen();
      case '/admin/expenses':
        return const ExpenseManagementScreen();
      case '/admin/config':
        return const SystemConfigScreen();
      case '/admin/reports':
        return SystemReportsScreen(onNavigate: _navigateTo);
      case '/admin/reports/production':
        return const ProductionReportScreen();
      case '/admin/reports/sales':
        return const SalesReportScreen();
      case '/admin/reports/expense':
        return const ExpenseReportScreen();
      case '/admin/reports/inventory':
        return const InventoryReportScreen();
      case '/admin/reports/performance':
        return const PerformanceReportScreen();
      default:
        return const AdminHomeScreen();
    }
  }

  String _getCurrentTitle() {
    switch (_currentRoute) {
      case '/admin/dashboard':
        return 'Dashboard Overview';
      case '/admin/users':
        return 'User Management';
      case '/admin/products':
        return 'Product Management';
      case '/admin/inventory':
        return 'Inventory Management';
      case '/admin/sales':
        return 'Sales Management';
      case '/admin/expenses':
        return 'Expense Management';
      case '/admin/config':
        return 'System Configuration';
      case '/admin/reports':
        return 'System Reports';
      case '/admin/reports/production':
        return 'Production Report';
      case '/admin/reports/sales':
        return 'Sales Report';
      case '/admin/reports/expense':
        return 'Expense Report';
      case '/admin/reports/inventory':
        return 'Inventory Report';
      case '/admin/reports/performance':
        return 'Performance Report';
      default:
        return 'Admin Panel';
    }
  }

  List<Widget> _getCurrentActions() {
    switch (_currentRoute) {
      case '/admin/users':
        // No action button - using FloatingActionButton in the screen
        return [];
      case '/admin/products':
        // No action button - using FloatingActionButton in the screen
        return [];
      case '/admin/inventory':
        // No action button - using FloatingActionButton in the screen
        return [];
      case '/admin/sales':
        return widget.onAddSale != null
            ? [
                AppButton(
                  text: 'New Sale',
                  onPressed: widget.onAddSale!,
                  icon: Icons.add,
                ),
                const SizedBox(width: AppStyles.space2),
              ]
            : [];
      case '/admin/expenses':
        return widget.onAddExpense != null
            ? [
                AppButton(
                  text: 'Add Expense',
                  onPressed: widget.onAddExpense!,
                  icon: Icons.add,
                ),
                const SizedBox(width: AppStyles.space2),
              ]
            : [];
      default:
        return [
          AppIconButton(
            icon: Icons.notifications,
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          const SizedBox(width: AppStyles.space2),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // On web, show persistent sidebar layout
    if (kIsWeb) {
      return Scaffold(
        body: Row(
          children: [
            // Persistent Sidebar
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  right: BorderSide(color: AppColors.gray200, width: 1),
                ),
              ),
              child: _buildSidebarContent(),
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // App Bar
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: AppColors.gray200, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.space4,
                    ),
                    child: Row(
                      children: [
                        if (_canGoBack) ...[
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _navigateBack,
                            tooltip: 'Go back',
                          ),
                          const SizedBox(width: AppStyles.space2),
                        ],
                        Text(_getCurrentTitle(), style: AppStyles.headingMd),
                        const Spacer(),
                        ..._getCurrentActions(),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(child: _getCurrentScreen()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // On mobile, use regular drawer
    return Scaffold(
      appBar: AppBar(
        title: Text(_getCurrentTitle()),
        actions: _getCurrentActions(),
      ),
      drawer: Drawer(child: _buildSidebarContent()),
      body: _getCurrentScreen(),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        // Enhanced Header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
          ),
          padding: EdgeInsets.only(
            top: kIsWeb
                ? AppStyles.space6
                : MediaQuery.of(context).padding.top + AppStyles.space4,
            bottom: AppStyles.space6,
            left: AppStyles.space4,
            right: AppStyles.space4,
          ),
          child: Column(
            children: [
              // Avatar with border
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.space4),

              // User Name
              Text(
                _userName.isEmpty ? 'Administrator' : _userName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppStyles.space2),

              // User Email
              Text(
                _userEmail.isEmpty ? 'admin@tsaci.com' : _userEmail,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppStyles.space3),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.space3,
                  vertical: AppStyles.space2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppStyles.space2),
                    Text(
                      'ADMINISTRATOR',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.space4),

              // Quick Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickAction(
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: () {
                      // TODO: Navigate to profile
                    },
                  ),
                  const SizedBox(width: AppStyles.space4),
                  _buildQuickAction(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                  ),
                ],
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
                title: 'Dashboard Overview',
                route: '/admin/dashboard',
                onTap: () {
                  // Only navigate if not already on dashboard
                  if (_currentRoute != '/admin/dashboard') {
                    _navigateTo('/admin/dashboard');
                  }
                },
              ),
              _buildSectionHeader('Management'),
              _buildMenuItem(
                icon: Icons.people,
                title: 'User Management',
                subtitle: 'Add, edit, delete users & roles',
                route: '/admin/users',
                onTap: () => _navigateTo('/admin/users'),
              ),
              _buildMenuItem(
                icon: Icons.inventory_2,
                title: 'Product Management',
                subtitle: 'Manage products & categories',
                route: '/admin/products',
                onTap: () => _navigateTo('/admin/products'),
              ),
              _buildMenuItem(
                icon: Icons.warehouse,
                title: 'Inventory Management',
                subtitle: 'Stock levels & alerts',
                route: '/admin/inventory',
                onTap: () => _navigateTo('/admin/inventory'),
              ),
              _buildMenuItem(
                icon: Icons.point_of_sale,
                title: 'Sales Management',
                subtitle: 'Orders & transactions',
                route: '/admin/sales',
                onTap: () => _navigateTo('/admin/sales'),
              ),
              _buildMenuItem(
                icon: Icons.receipt_long,
                title: 'Expense Management',
                subtitle: 'Track expenses & costs',
                route: '/admin/expenses',
                onTap: () => _navigateTo('/admin/expenses'),
              ),
              _buildSectionHeader('System'),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'System Configuration',
                subtitle: 'Stages, units, white labeling',
                route: '/admin/config',
                onTap: () => _navigateTo('/admin/config'),
              ),
              _buildMenuItem(
                icon: Icons.assessment,
                title: 'Reports',
                subtitle: 'Generate & export reports',
                route: '/admin/reports',
                onTap: () => _navigateTo('/admin/reports'),
              ),
            ],
          ),
        ),

        // Footer
        const Divider(height: 1),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          route: '/logout',
          color: AppColors.error,
          onTap: _handleLogout,
        ),
        const SizedBox(height: AppStyles.space2),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space2,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: AppStyles.space2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
    Color? color,
  }) {
    final isSelected = _currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppStyles.space2,
        vertical: AppStyles.space1,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 1)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : (color ?? AppColors.textPrimary),
          size: 24,
        ),
        title: Text(
          title,
          style: AppStyles.labelMd.copyWith(
            color: isSelected ? AppColors.primary : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppStyles.labelSm.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space1,
        ),
      ),
    );
  }
}
