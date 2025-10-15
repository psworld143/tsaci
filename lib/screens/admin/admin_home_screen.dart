import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      final response = await ApiService.get(
        '${ApiConstants.baseUrl}/reports/dashboard',
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _dashboardData = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingState();
    }

    final kpis = _dashboardData?['kpis'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Text('Key Performance Indicators', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 4,
            spacing: AppStyles.space3,
            children: [
              _buildKPICard(
                title: 'Production Batches',
                value: '${kpis['total_batches'] ?? 0}',
                icon: Icons.factory,
                color: AppColors.primary,
              ),
              _buildKPICard(
                title: 'Total Materials',
                value: '${kpis['total_materials'] ?? 0}',
                icon: Icons.inventory,
                color: AppColors.info,
              ),
              _buildKPICard(
                title: 'Low Stock Alerts',
                value: '${kpis['low_stock_alerts'] ?? 0}',
                icon: Icons.warning,
                color: AppColors.warning,
              ),
              _buildKPICard(
                title: 'Active Users',
                value: '${kpis['active_users'] ?? 0}',
                icon: Icons.people,
                color: AppColors.success,
              ),
            ],
          ),

          const SizedBox(height: AppStyles.space6),

          // Charts Section
          Text('Analytics Overview', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),

          // Financial Overview Chart
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 2,
            spacing: AppStyles.space4,
            children: [_buildFinancialChart(), _buildKPIDistributionChart()],
          ),

          const SizedBox(height: AppStyles.space6),

          // Activity Logs
          Text('Recent Activity', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.space4),
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.login,
                    title: 'Admin logged in',
                    time: 'Just now',
                  ),
                  const Divider(),
                  _buildActivityItem(
                    icon: Icons.add,
                    title: 'New user created',
                    time: '5 minutes ago',
                  ),
                  const Divider(),
                  _buildActivityItem(
                    icon: Icons.edit,
                    title: 'Product updated',
                    time: '10 minutes ago',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialChart() {
    final monthly = _dashboardData?['monthly'] ?? {};
    final totalSales = (monthly['total_sales'] ?? 0).toDouble();
    final totalExpenses = (monthly['total_expenses'] ?? 0).toDouble();
    final netIncome = (monthly['net_income'] ?? 0).toDouble();

    // Calculate max value with safety checks
    final maxValue = [
      totalSales,
      totalExpenses,
      netIncome.abs(),
    ].reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxValue > 0 ? maxValue * 1.2 : 100;
    final interval = chartMaxY / 5;

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
                    Icons.trending_up,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Monthly Financial Overview', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        switch (group.x) {
                          case 0:
                            label = 'Sales';
                            break;
                          case 1:
                            label = 'Expenses';
                            break;
                          case 2:
                            label = 'Net Income';
                            break;
                          default:
                            label = '';
                        }
                        return BarTooltipItem(
                          '$label\n₱${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text(
                                'Sales',
                                style: AppStyles.labelSm,
                              );
                            case 1:
                              return const Text(
                                'Expenses',
                                style: AppStyles.labelSm,
                              );
                            case 2:
                              return const Text(
                                'Net',
                                style: AppStyles.labelSm,
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: interval > 0 ? interval : null,
                        getTitlesWidget: (value, meta) {
                          if (value >= 1000000) {
                            return Text(
                              '₱${(value / 1000000).toStringAsFixed(1)}M',
                              style: AppStyles.bodyXs,
                            );
                          } else if (value >= 1000) {
                            return Text(
                              '₱${(value / 1000).toStringAsFixed(0)}K',
                              style: AppStyles.bodyXs,
                            );
                          }
                          return Text(
                            '₱${value.toInt()}',
                            style: AppStyles.bodyXs,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval > 0 ? interval : null,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: AppColors.gray200, strokeWidth: 1);
                    },
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalSales > 0 ? totalSales : 0.1,
                          color: AppColors.success,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalExpenses > 0 ? totalExpenses : 0.1,
                          color: AppColors.error,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: netIncome > 0 ? netIncome : 0.1,
                          color: AppColors.primary,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space4),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Sales', AppColors.success),
                _buildLegendItem('Expenses', AppColors.error),
                _buildLegendItem('Net Income', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIDistributionChart() {
    final kpis = _dashboardData?['kpis'] ?? {};
    final totalBatches = (kpis['total_batches'] ?? 0).toDouble();
    final totalMaterials = (kpis['total_materials'] ?? 0).toDouble();
    final lowStockAlerts = (kpis['low_stock_alerts'] ?? 0).toDouble();
    final activeUsers = (kpis['active_users'] ?? 0).toDouble();

    final sections = [
      if (totalBatches > 0)
        PieChartSectionData(
          value: totalBatches,
          title: '${totalBatches.toInt()}',
          color: AppColors.primary,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (totalMaterials > 0)
        PieChartSectionData(
          value: totalMaterials,
          title: '${totalMaterials.toInt()}',
          color: AppColors.info,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (lowStockAlerts > 0)
        PieChartSectionData(
          value: lowStockAlerts,
          title: '${lowStockAlerts.toInt()}',
          color: AppColors.warning,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (activeUsers > 0)
        PieChartSectionData(
          value: activeUsers,
          title: '${activeUsers.toInt()}',
          color: AppColors.success,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

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
                    Icons.pie_chart,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('System Metrics Distribution', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: sections.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: AppStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: AppStyles.space4),
            // Legend
            Wrap(
              spacing: AppStyles.space3,
              runSpacing: AppStyles.space2,
              children: [
                if (totalBatches > 0)
                  _buildLegendItem('Production', AppColors.primary),
                if (totalMaterials > 0)
                  _buildLegendItem('Materials', AppColors.info),
                if (lowStockAlerts > 0)
                  _buildLegendItem('Alerts', AppColors.warning),
                if (activeUsers > 0)
                  _buildLegendItem('Users', AppColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppStyles.space1),
        Text(label, style: AppStyles.bodySm),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return StatCard(title: title, value: value, icon: icon, color: color);
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.space2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusSm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppStyles.space3),
          Expanded(child: Text(title, style: AppStyles.labelMd)),
          Text(
            time,
            style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
