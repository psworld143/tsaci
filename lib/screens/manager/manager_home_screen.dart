import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/app_drawer.dart';
import '../../models/dashboard_model.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../utils/responsive.dart';
import 'production_report_screen.dart';
import 'sales_report_screen.dart';
import 'expense_report_screen.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({Key? key}) : super(key: key);

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _error;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() => _userName = user.name);
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await DashboardService.getDashboardData();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableAppScaffold(
      title: 'Dashboard',
      onRefresh: _loadDashboardData,
      useResponsiveContainer: false,
      showBackButton: false,
      drawer: const AppDrawer(userRole: 'manager'),
      actions: [
        AppIconButton(
          icon: Icons.notifications,
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        const SizedBox(width: AppStyles.space2),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content
          if (_isLoading)
            const SizedBox(
              height: 300,
              child: AppLoadingState(message: 'Loading dashboard...'),
            )
          else if (_error != null)
            SizedBox(
              height: 300,
              child: AppErrorState(
                title: 'Failed to load dashboard',
                subtitle: _error,
                onRetry: _loadDashboardData,
              ),
            )
          else if (_dashboardData != null)
            _buildDashboardContent(_dashboardData!),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards - Responsive Grid
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 4,
          spacing: AppStyles.space4,
          children: [
            StatCard(
              title: 'Total Income',
              value: '₱${_formatNumber(data.monthly.totalSales)}',
              icon: Icons.trending_up,
              color: AppColors.success,
              subtitle: 'This month',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesReportScreen()),
              ),
            ),
            StatCard(
              title: 'Total Expenses',
              value: '₱${_formatNumber(data.monthly.totalExpenses)}',
              icon: Icons.trending_down,
              color: AppColors.error,
              subtitle: 'This month',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseReportScreen()),
              ),
            ),
            StatCard(
              title: 'Net Income',
              value: '₱${_formatNumber(data.monthly.netIncome)}',
              icon: Icons.account_balance_wallet,
              color: AppColors.primary,
              subtitle: 'Profit',
            ),
            StatCard(
              title: 'Production',
              value: '${data.today.productionLogs}',
              icon: Icons.factory,
              color: AppColors.info,
              subtitle: 'Logs today',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductionReportScreen(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space6),

        // Top Product
        if (data.topProduct != null) ...[
          Text('Top Selling Product', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          AppCard(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: const Icon(Icons.star, color: AppColors.success),
              ),
              title: Text(data.topProduct!.name, style: AppStyles.labelLg),
              subtitle: Text(
                '${data.topProduct!.quantitySold} units sold',
                style: AppStyles.bodySm,
              ),
              trailing: Text(
                '₱${_formatNumber(data.topProduct!.totalSales)}',
                style: AppStyles.labelLg.copyWith(color: AppColors.success),
              ),
            ),
          ),
          const SizedBox(height: AppStyles.space6),
        ],

        // Alerts
        if (data.alerts.lowStockCount > 0) ...[
          AppCard(
            color: AppColors.warning.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.warning, color: AppColors.warning),
              title: Text(
                'Low Stock Alert',
                style: AppStyles.labelLg.copyWith(color: AppColors.warning),
              ),
              subtitle: Text(
                '${data.alerts.lowStockCount} items below minimum threshold',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const SizedBox(height: AppStyles.space6),
        ],

        // Quick Actions
        Text('Quick Actions', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        ResponsiveLayout(
          mobile: Column(
            children: [
              AppButton(
                text: 'Production Report',
                icon: Icons.factory,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductionReportScreen(),
                  ),
                ),
                variant: ButtonVariant.outline,
                fullWidth: true,
              ),
              const SizedBox(height: AppStyles.space2),
              AppButton(
                text: 'Sales Report',
                icon: Icons.point_of_sale,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                ),
                variant: ButtonVariant.outline,
                fullWidth: true,
              ),
              const SizedBox(height: AppStyles.space2),
              AppButton(
                text: 'Expense Report',
                icon: Icons.receipt,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExpenseReportScreen(),
                  ),
                ),
                variant: ButtonVariant.outline,
                fullWidth: true,
              ),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Production',
                  icon: Icons.factory,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductionReportScreen(),
                    ),
                  ),
                  variant: ButtonVariant.outline,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Expanded(
                child: AppButton(
                  text: 'Sales',
                  icon: Icons.point_of_sale,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SalesReportScreen(),
                    ),
                  ),
                  variant: ButtonVariant.outline,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Expanded(
                child: AppButton(
                  text: 'Expenses',
                  icon: Icons.receipt,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpenseReportScreen(),
                    ),
                  ),
                  variant: ButtonVariant.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
