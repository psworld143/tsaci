import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'production_manager_home_screen.dart';
import 'production_planning_screen.dart';
import 'batch_tracking_screen.dart';
import 'material_usage_screen.dart';
import 'worker_supervision_screen.dart';
import 'production_reports_screen.dart';

/// Production Manager Layout with Persistent Sidebar for Web
class ProductionManagerLayout extends StatefulWidget {
  final String? initialRoute;

  const ProductionManagerLayout({Key? key, this.initialRoute})
    : super(key: key);

  @override
  State<ProductionManagerLayout> createState() =>
      _ProductionManagerLayoutState();
}

class _ProductionManagerLayoutState extends State<ProductionManagerLayout> {
  String _userName = '';
  String _userEmail = '';
  String _currentRoute = '/production/dashboard';
  final List<String> _navigationHistory = ['/production/dashboard'];

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute ?? '/production/dashboard';
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
      case '/production/dashboard':
        return const ProductionManagerHomeScreen();
      case '/production/planning':
        return const ProductionPlanningScreen();
      case '/production/batches':
        return const BatchTrackingScreen();
      case '/production/materials':
        return const MaterialUsageScreen();
      case '/production/workers':
        return const WorkerSupervisionScreen();
      case '/production/reports':
        return const ProductionReportsScreen();
      default:
        return const ProductionManagerHomeScreen();
    }
  }

  String _getCurrentTitle() {
    switch (_currentRoute) {
      case '/production/dashboard':
        return 'Production Dashboard';
      case '/production/planning':
        return 'Production Planning';
      case '/production/batches':
        return 'Batch Tracking';
      case '/production/materials':
        return 'Material Usage';
      case '/production/workers':
        return 'Worker Supervision';
      case '/production/reports':
        return 'Production Reports';
      default:
        return 'Production Manager';
    }
  }

  @override
  Widget build(BuildContext context) {
    // On web/desktop, use persistent sidebar
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
      appBar: AppBar(title: Text(_getCurrentTitle())),
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
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(AppStyles.space6),
          child: Column(
            children: [
              // User Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.factory, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: AppStyles.space3),

              // User Info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.space3,
                  vertical: AppStyles.space2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Column(
                  children: [
                    Text(
                      _userName.isEmpty ? 'Production Manager' : _userName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppStyles.space1),
                    Text(
                      _userEmail.isEmpty ? 'manager@tsaci.com' : _userEmail,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppStyles.space2),
                    Text(
                      'PRODUCTION MANAGER',
                      style: GoogleFonts.poppins(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
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
                route: '/production/dashboard',
                onTap: () {
                  if (_currentRoute != '/production/dashboard') {
                    _navigateTo('/production/dashboard');
                  }
                },
              ),
              _buildSectionHeader('Production Management'),
              _buildMenuItem(
                icon: Icons.add_box,
                title: 'Production Planning',
                subtitle: 'Create & schedule batches',
                route: '/production/planning',
                onTap: () => _navigateTo('/production/planning'),
              ),
              _buildMenuItem(
                icon: Icons.track_changes,
                title: 'Batch Tracking',
                subtitle: 'Monitor batch progress',
                route: '/production/batches',
                onTap: () => _navigateTo('/production/batches'),
              ),
              _buildMenuItem(
                icon: Icons.inventory_2,
                title: 'Material Usage',
                subtitle: 'Approve withdrawals',
                route: '/production/materials',
                onTap: () => _navigateTo('/production/materials'),
              ),
              _buildMenuItem(
                icon: Icons.people,
                title: 'Worker Supervision',
                subtitle: 'Manage workers & feedback',
                route: '/production/workers',
                onTap: () => _navigateTo('/production/workers'),
              ),
              _buildSectionHeader('Reports'),
              _buildMenuItem(
                icon: Icons.assessment,
                title: 'Production Reports',
                subtitle: 'Efficiency & utilization',
                route: '/production/reports',
                onTap: () => _navigateTo('/production/reports'),
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
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1,
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
    final isActive = _currentRoute == route;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppStyles.space2,
          vertical: AppStyles.space1,
        ),
        padding: const EdgeInsets.all(AppStyles.space3),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          border: isActive
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  color ??
                  (isActive ? AppColors.primary : AppColors.textSecondary),
              size: 20,
            ),
            const SizedBox(width: AppStyles.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color:
                          color ??
                          (isActive
                              ? AppColors.primary
                              : AppColors.textPrimary),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isActive)
              Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
