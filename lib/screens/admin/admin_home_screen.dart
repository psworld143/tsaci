import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../services/api_service.dart';
import '../../services/production_service.dart';
import '../../services/sales_service.dart';
import '../../services/inventory_service.dart';
import '../../services/quality_inspection_service.dart';
import '../../core/constants/api_constants.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic> _realtimeStats = {};
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadRealtimeStats();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadRealtimeStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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

  Future<void> _loadRealtimeStats() async {
    try {
      // Load data from all services
      final productions = await ProductionService.getAll(limit: 100);
      final salesService = SalesService();
      final inventoryService = InventoryService();
      final sales = await salesService.getAllSales();
      final inventory = await inventoryService.getAllInventory();
      final inspections = await QualityInspectionService.getAllInspections();
      final qaStats = await QualityInspectionService.getStatistics();

      // Calculate operations by role
      final productionManagerOps = productions.length;
      final qaOfficerOps = inspections.length;
      final inventoryOfficerOps = inventory.length;
      final salesOps = sales.length;

      if (mounted) {
        setState(() {
          _realtimeStats = {
            'production_count': productions.length,
            'sales_count': sales.length,
            'inventory_count': inventory.length,
            'inspections_count': inspections.length,
            'qa_pass_rate': double.tryParse(qaStats['pass_rate'] ?? '0') ?? 0.0,
            'low_stock_count': inventory.where((i) => i.isLowStock).length,
            'production_efficiency': productions.isNotEmpty
                ? productions.fold<double>(0, (sum, p) => sum + p.efficiency) /
                      productions.length
                : 0.0,
            'role_operations': {
              'production_manager': productionManagerOps,
              'qa_officer': qaOfficerOps,
              'inventory_officer': inventoryOfficerOps,
              'admin': salesOps,
            },
          };
        });
      }
    } catch (e) {
      // Handle error silently
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

          // Real-Time Operations Header
          Row(
            children: [
              Text('Real-Time Operations', style: AppStyles.headingSm),
              const SizedBox(width: AppStyles.space2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.space2,
                  vertical: AppStyles.space1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: AppStyles.labelSm.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space4),

          // Real-Time Stats Cards
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 4,
            desktopColumns: 6,
            spacing: AppStyles.space3,
            children: [
              _buildRealTimeCard(
                'Production',
                '${_realtimeStats['production_count'] ?? 0}',
                Icons.factory,
                AppColors.primary,
              ),
              _buildRealTimeCard(
                'Sales',
                '${_realtimeStats['sales_count'] ?? 0}',
                Icons.point_of_sale,
                AppColors.success,
              ),
              _buildRealTimeCard(
                'Inventory',
                '${_realtimeStats['inventory_count'] ?? 0}',
                Icons.warehouse,
                AppColors.info,
              ),
              _buildRealTimeCard(
                'QA Tests',
                '${_realtimeStats['inspections_count'] ?? 0}',
                Icons.verified,
                const Color(0xFF9C27B0), // Purple color
              ),
              _buildRealTimeCard(
                'Low Stock',
                '${_realtimeStats['low_stock_count'] ?? 0}',
                Icons.warning,
                AppColors.warning,
              ),
              _buildRealTimeCard(
                'QA Pass Rate',
                '${_realtimeStats['qa_pass_rate']?.toStringAsFixed(1) ?? '0'}%',
                Icons.check_circle,
                AppColors.success,
              ),
            ],
          ),

          const SizedBox(height: AppStyles.space6),

          // Charts Section
          Text('Analytics Overview', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),

          // Operations by User Role Chart + Financial Chart
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 2,
            spacing: AppStyles.space4,
            children: [_buildRoleOperationsChart(), _buildFinancialChart()],
          ),

          const SizedBox(height: AppStyles.space4),

          // Production Efficiency + Inventory Status Charts
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 2,
            spacing: AppStyles.space4,
            children: [
              _buildProductionEfficiencyChart(),
              _buildKPIDistributionChart(),
            ],
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

  Widget _buildRealTimeCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppStyles.space2),
          Text(value, style: AppStyles.headingMd.copyWith(color: color)),
          Text(
            title,
            style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOperationsChart() {
    final roleOps =
        _realtimeStats['role_operations'] as Map<String, dynamic>? ?? {};
    final productionMgr = (roleOps['production_manager'] ?? 0).toDouble();
    final qaOfficer = (roleOps['qa_officer'] ?? 0).toDouble();
    final inventoryOfficer = (roleOps['inventory_officer'] ?? 0).toDouble();
    final admin = (roleOps['admin'] ?? 0).toDouble();

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
                    Icons.people,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Operations by User Role', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  maxY:
                      [
                        productionMgr,
                        qaOfficer,
                        inventoryOfficer,
                        admin,
                      ].reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        switch (group.x) {
                          case 0:
                            label = 'Production Manager';
                            break;
                          case 1:
                            label = 'QA Officer';
                            break;
                          case 2:
                            label = 'Inventory Officer';
                            break;
                          case 3:
                            label = 'Admin';
                            break;
                          default:
                            label = '';
                        }
                        return BarTooltipItem(
                          '$label\n${rod.toY.toInt()} operations',
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
                              return Column(
                                children: const [
                                  Icon(
                                    Icons.factory,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Prod\nMgr',
                                    style: AppStyles.bodyXs,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            case 1:
                              return Column(
                                children: const [
                                  Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Color(0xFF9C27B0),
                                  ),
                                  SizedBox(height: 2),
                                  Text('QA', style: AppStyles.bodyXs),
                                ],
                              );
                            case 2:
                              return Column(
                                children: const [
                                  Icon(
                                    Icons.warehouse,
                                    size: 16,
                                    color: AppColors.info,
                                  ),
                                  SizedBox(height: 2),
                                  Text('Inventory', style: AppStyles.bodyXs),
                                ],
                              );
                            case 3:
                              return Column(
                                children: const [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(height: 2),
                                  Text('Admin', style: AppStyles.bodyXs),
                                ],
                              );
                            default:
                              return const Text('');
                          }
                        },
                        reservedSize: 50,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
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
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: AppColors.gray200, strokeWidth: 1);
                    },
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: productionMgr > 0 ? productionMgr : 0.1,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 35,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: qaOfficer > 0 ? qaOfficer : 0.1,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF9C27B0),
                              const Color(0xFF9C27B0).withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 35,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: inventoryOfficer > 0 ? inventoryOfficer : 0.1,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.info,
                              AppColors.info.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 35,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: admin > 0 ? admin : 0.1,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success,
                              AppColors.success.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 35,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionEfficiencyChart() {
    final efficiency = _realtimeStats['production_efficiency'] ?? 0.0;

    // Create gradient sections
    final sections = [
      PieChartSectionData(
        value: efficiency,
        title: '${efficiency.toStringAsFixed(1)}%',
        color: efficiency >= 90
            ? AppColors.success
            : efficiency >= 70
            ? AppColors.warning
            : AppColors.error,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (100 - efficiency).toDouble(),
        title: '',
        color: AppColors.gray200,
        radius: 100,
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
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: const Icon(
                    Icons.speed,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Production Efficiency', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space4),
            Center(
              child: Text(
                'Average Efficiency',
                style: AppStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
