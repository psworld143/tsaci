import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class PerformanceReportScreen extends StatefulWidget {
  const PerformanceReportScreen({Key? key}) : super(key: key);

  @override
  State<PerformanceReportScreen> createState() =>
      _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get(
        '${ApiConstants.baseUrl}/reports/dashboard',
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _dashboardData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load performance data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're inside a Scaffold already (AdminLayout)
    final hasScaffold = Scaffold.maybeOf(context) != null;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          const SizedBox(
            height: 300,
            child: AppLoadingState(message: 'Loading performance data...'),
          )
        else if (_error != null)
          SizedBox(
            height: 300,
            child: AppErrorState(
              title: 'Failed to load data',
              subtitle: _error,
              onRetry: _loadPerformanceData,
            ),
          )
        else if (_dashboardData != null)
          _buildPerformanceReport(),
      ],
    );

    // If inside AdminLayout, just return scrollable content
    if (hasScaffold) {
      return RefreshIndicator(
        onRefresh: _loadPerformanceData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.space4),
          child: content,
        ),
      );
    }

    // Otherwise, use full scaffold (for Manager drawer navigation)
    return ScrollableAppScaffold(
      title: 'Performance Report',
      onRefresh: _loadPerformanceData,
      useResponsiveContainer: false,
      child: content,
    );
  }

  Widget _buildPerformanceReport() {
    final kpis = _dashboardData?['kpis'] ?? {};
    final monthly = _dashboardData?['monthly'] ?? {};
    final today = _dashboardData?['today'] ?? {};

    final totalBatches = kpis['total_batches'] ?? 0;
    final totalMaterials = kpis['total_materials'] ?? 0;
    final lowStockAlerts = kpis['low_stock_alerts'] ?? 0;
    final activeUsers = kpis['active_users'] ?? 0;
    final totalSales = (monthly['total_sales'] ?? 0).toDouble();
    final totalExpenses = (monthly['total_expenses'] ?? 0).toDouble();
    final netIncome = (monthly['net_income'] ?? 0).toDouble();
    final productionToday = today['production_logs'] ?? 0;

    // Calculate performance metrics
    final profitMargin = totalSales > 0 ? ((netIncome / totalSales) * 100) : 0;
    final stockAlertRate = totalMaterials > 0
        ? ((lowStockAlerts / totalMaterials) * 100)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Text('System Performance Metrics', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 4,
          spacing: AppStyles.space4,
          children: [
            StatCard(
              title: 'Profit Margin',
              value: '${profitMargin.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: profitMargin >= 20 ? AppColors.success : AppColors.warning,
              subtitle: profitMargin >= 20 ? 'Excellent' : 'Need Improvement',
            ),
            StatCard(
              title: 'Stock Alert Rate',
              value: '${stockAlertRate.toStringAsFixed(1)}%',
              icon: Icons.warning,
              color: stockAlertRate <= 10
                  ? AppColors.success
                  : AppColors.warning,
              subtitle: stockAlertRate <= 10 ? 'Good' : 'Review Stock',
            ),
            StatCard(
              title: 'Daily Production',
              value: '$productionToday',
              icon: Icons.factory,
              color: AppColors.primary,
              subtitle: 'Logs today',
            ),
            StatCard(
              title: 'System Health',
              value: '${_calculateSystemHealth()}%',
              icon: Icons.health_and_safety,
              color: _getHealthColor(_calculateSystemHealth()),
              subtitle: _getHealthLabel(_calculateSystemHealth()),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space6),

        // Charts
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          spacing: AppStyles.space4,
          children: [
            _buildFinancialPerformanceChart(
              totalSales,
              totalExpenses,
              netIncome,
            ),
            _buildSystemMetricsChart(
              totalBatches,
              totalMaterials,
              activeUsers,
              lowStockAlerts,
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space6),

        // Performance Indicators
        Text('Key Performance Indicators', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        AppCard(
          child: Column(
            children: [
              _buildPerformanceIndicator(
                'Production Efficiency',
                totalBatches > 0 ? 85.0 : 0,
                Icons.factory,
                AppColors.primary,
              ),
              const Divider(),
              _buildPerformanceIndicator(
                'Inventory Management',
                stockAlertRate <= 10 ? 90.0 : 70.0,
                Icons.warehouse,
                stockAlertRate <= 10 ? AppColors.success : AppColors.warning,
              ),
              const Divider(),
              _buildPerformanceIndicator(
                'Financial Health',
                profitMargin >= 20 ? 95.0 : 75.0,
                Icons.attach_money,
                profitMargin >= 20 ? AppColors.success : AppColors.warning,
              ),
              const Divider(),
              _buildPerformanceIndicator(
                'User Engagement',
                activeUsers > 0 ? 80.0 : 50.0,
                Icons.people,
                activeUsers > 0 ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _calculateSystemHealth() {
    final kpis = _dashboardData?['kpis'] ?? {};
    final monthly = _dashboardData?['monthly'] ?? {};

    int healthScore = 100;

    // Deduct points for issues
    final lowStockAlerts = kpis['low_stock_alerts'] ?? 0;
    if (lowStockAlerts > 5)
      healthScore -= 15;
    else if (lowStockAlerts > 2)
      healthScore -= 10;

    final netIncome = (monthly['net_income'] ?? 0).toDouble();
    if (netIncome <= 0) healthScore -= 20;

    final activeUsers = kpis['active_users'] ?? 0;
    if (activeUsers == 0) healthScore -= 15;

    return healthScore.clamp(0, 100);
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return AppColors.success;
    if (health >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getHealthLabel(int health) {
    if (health >= 80) return 'Excellent';
    if (health >= 60) return 'Good';
    return 'Needs Attention';
  }

  Widget _buildFinancialPerformanceChart(
    double sales,
    double expenses,
    double netIncome,
  ) {
    final total = sales + expenses;
    final salesPercentage = total > 0 ? (sales / total * 100).toDouble() : 50.0;
    final expensesPercentage = total > 0
        ? (expenses / total * 100).toDouble()
        : 50.0;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.space2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Financial Performance', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            _buildProgressBar('Sales', salesPercentage, AppColors.success),
            const SizedBox(height: AppStyles.space3),
            _buildProgressBar('Expenses', expensesPercentage, AppColors.error),
            const SizedBox(height: AppStyles.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem('Revenue', '₱${sales.toStringAsFixed(0)}'),
                _buildMetricItem('Costs', '₱${expenses.toStringAsFixed(0)}'),
                _buildMetricItem('Net', '₱${netIncome.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMetricsChart(
    int batches,
    int materials,
    int users,
    int alerts,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.space2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('System Metrics', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            _buildMetricRow(
              'Production Batches',
              batches,
              Icons.factory,
              AppColors.primary,
            ),
            const SizedBox(height: AppStyles.space3),
            _buildMetricRow(
              'Total Materials',
              materials,
              Icons.inventory,
              AppColors.info,
            ),
            const SizedBox(height: AppStyles.space3),
            _buildMetricRow(
              'Active Users',
              users,
              Icons.people,
              AppColors.success,
            ),
            const SizedBox(height: AppStyles.space3),
            _buildMetricRow(
              'Stock Alerts',
              alerts,
              Icons.warning,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppStyles.labelMd),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: AppStyles.labelMd.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space2),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: AppColors.gray200,
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(AppStyles.radiusSm),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppStyles.labelSm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppStyles.space1),
        Text(value, style: AppStyles.labelLg),
      ],
    );
  }

  Widget _buildMetricRow(String label, int value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppStyles.space2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppStyles.radiusSm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppStyles.space3),
        Expanded(child: Text(label, style: AppStyles.labelMd)),
        Text('$value', style: AppStyles.headingSm.copyWith(color: color)),
      ],
    );
  }

  Widget _buildPerformanceIndicator(
    String title,
    double score,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppStyles.space2),
              Expanded(child: Text(title, style: AppStyles.labelMd)),
              Text(
                '${score.toStringAsFixed(0)}%',
                style: AppStyles.headingSm.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space2),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.gray200,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppStyles.radiusSm),
          ),
        ],
      ),
    );
  }
}
