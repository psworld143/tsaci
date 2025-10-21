import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../models/inventory_model.dart';
import '../../services/inventory_service.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({Key? key}) : super(key: key);

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryModel> _inventory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final inventory = await _inventoryService.getAllInventory();

      setState(() {
        _inventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Map<String, int> _getCategoryDistribution() {
    final Map<String, int> distribution = {};
    for (var item in _inventory) {
      distribution[item.category] = (distribution[item.category] ?? 0) + 1;
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're inside a Scaffold already (AdminLayout)
    final hasScaffold = Scaffold.maybeOf(context) != null;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content
        if (_isLoading)
          const SizedBox(
            height: 300,
            child: AppLoadingState(message: 'Loading inventory data...'),
          )
        else if (_error != null)
          SizedBox(
            height: 300,
            child: AppErrorState(
              title: 'Failed to load data',
              subtitle: _error,
              onRetry: _loadInventory,
            ),
          )
        else if (_inventory.isEmpty)
          const SizedBox(
            height: 300,
            child: AppEmptyState(
              icon: Icons.warehouse,
              title: 'No inventory data',
              subtitle: 'No inventory items found',
            ),
          )
        else
          _buildInventoryReport(),

        // Analytics Section
        if (!_isLoading && _error == null && _inventory.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildAnalyticsSection(),
        ],

        // Charts Section
        if (!_isLoading && _error == null && _inventory.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildChartsSection(),
        ],

        // Predictive Analysis
        if (!_isLoading && _error == null && _inventory.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildPredictiveAnalysis(),
        ],
      ],
    );

    // If inside AdminLayout, just return scrollable content
    if (hasScaffold) {
      return RefreshIndicator(
        onRefresh: _loadInventory,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.space4),
          child: content,
        ),
      );
    }

    // Otherwise, use full scaffold (for Manager drawer navigation)
    return ScrollableAppScaffold(
      title: 'Inventory Report',
      onRefresh: _loadInventory,
      useResponsiveContainer: false,
      child: content,
    );
  }

  Widget _buildInventoryReport() {
    final totalItems = _inventory.length;
    final lowStockItems = _inventory.where((item) => item.isLowStock).length;
    final totalQuantity = _inventory.fold<double>(
      0.0,
      (sum, item) => sum + item.quantity,
    );
    final categoryDistribution = _getCategoryDistribution();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 4,
          desktopColumns: 4,
          spacing: AppStyles.space4,
          children: [
            StatCard(
              title: 'Total Items',
              value: '$totalItems',
              icon: Icons.inventory,
              color: AppColors.primary,
            ),
            StatCard(
              title: 'Total Quantity',
              value: totalQuantity.toStringAsFixed(0),
              icon: Icons.numbers,
              color: AppColors.info,
            ),
            StatCard(
              title: 'Low Stock',
              value: '$lowStockItems',
              icon: Icons.warning,
              color: AppColors.warning,
            ),
            StatCard(
              title: 'Categories',
              value: '${categoryDistribution.length}',
              icon: Icons.category,
              color: AppColors.success,
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
            _buildStockLevelsChart(),
            _buildCategoryDistributionPieChart(categoryDistribution),
          ],
        ),
        const SizedBox(height: AppStyles.space6),

        // Inventory List
        Text(
          'Inventory Details (${_inventory.length} items)',
          style: AppStyles.headingSm,
        ),
        const SizedBox(height: AppStyles.space4),
        ...List.generate(_inventory.length, (index) {
          final item = _inventory[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppStyles.space3),
            child: AppCard(
              border: item.isLowStock
                  ? Border.all(color: AppColors.warning, width: 2)
                  : null,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space3),
                    decoration: BoxDecoration(
                      color:
                          (item.isLowStock
                                  ? AppColors.warning
                                  : AppColors.success)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    child: Icon(
                      item.isLowStock ? Icons.warning : Icons.inventory,
                      color: item.isLowStock
                          ? AppColors.warning
                          : AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: AppStyles.labelLg),
                        const SizedBox(height: AppStyles.space1),
                        Text(
                          '${item.category} • ${item.location}',
                          style: AppStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (item.isLowStock) ...[
                          const SizedBox(height: AppStyles.space1),
                          Text(
                            'LOW STOCK ALERT',
                            style: AppStyles.labelSm.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.quantity}',
                        style: AppStyles.headingSm.copyWith(
                          color: item.isLowStock
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                      Text(
                        'Min: ${item.minimumThreshold}',
                        style: AppStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStockLevelsChart() {
    // Group items by stock status
    final healthyStock = _inventory.where((item) => !item.isLowStock).length;
    final lowStock = _inventory.where((item) => item.isLowStock).length;

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
                    Icons.show_chart,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Stock Health Status', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: healthyStock.toDouble(),
                      title: '$healthyStock',
                      color: AppColors.success,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: lowStock.toDouble(),
                      title: '$lowStock',
                      color: AppColors.warning,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Healthy Stock', AppColors.success),
                _buildLegendItem('Low Stock', AppColors.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionPieChart(Map<String, int> distribution) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedEntries.take(5).toList();

    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
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
                Text('Items by Category', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: topCategories.isEmpty
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
                        sections: topCategories.asMap().entries.map((entry) {
                          return PieChartSectionData(
                            value: entry.value.value.toDouble(),
                            title: '${entry.value.value}',
                            color: colors[entry.key % colors.length],
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 45,
                      ),
                    ),
            ),
            const SizedBox(height: AppStyles.space4),
            Wrap(
              spacing: AppStyles.space3,
              runSpacing: AppStyles.space2,
              children: topCategories.asMap().entries.map((entry) {
                return _buildLegendItem(
                  entry.value.key,
                  colors[entry.key % colors.length],
                );
              }).toList(),
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

  // Analytics Section
  Widget _buildAnalyticsSection() {
    final totalItems = _inventory.length;
    final totalStockValue = _inventory.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * 100),
    ); // Assuming 100 per unit
    final lowStockItems = _inventory
        .where((item) => item.quantity < item.minimumThreshold)
        .length;
    final outOfStockItems = _inventory
        .where((item) => item.quantity == 0)
        .length;

    // Category count
    final categories = _inventory.map((item) => item.category).toSet();
    final categoryCount = categories.length;

    // Average stock level
    final avgStockLevel = _inventory.isNotEmpty
        ? _inventory.fold<double>(0, (sum, item) => sum + item.quantity) /
              _inventory.length
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inventory Analytics', style: AppStyles.headingMd),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: AppStyles.space4,
          children: [
            _buildAnalyticsCard(
              'Total Items',
              totalItems.toString(),
              Icons.inventory_2,
              AppColors.primary,
            ),
            _buildAnalyticsCard(
              'Total Stock Value',
              '₱${totalStockValue.toStringAsFixed(0)}',
              Icons.attach_money,
              AppColors.success,
            ),
            _buildAnalyticsCard(
              'Low Stock Items',
              lowStockItems.toString(),
              Icons.warning,
              AppColors.warning,
            ),
            _buildAnalyticsCard(
              'Out of Stock',
              outOfStockItems.toString(),
              Icons.error,
              AppColors.error,
            ),
            _buildAnalyticsCard(
              'Category Count',
              categoryCount.toString(),
              Icons.category,
              AppColors.info,
            ),
            _buildAnalyticsCard(
              'Average Stock Level',
              '${avgStockLevel.toStringAsFixed(1)}',
              Icons.analytics,
              AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppStyles.space2),
              Expanded(child: Text(title, style: AppStyles.labelMd)),
            ],
          ),
          const SizedBox(height: AppStyles.space2),
          Text(value, style: AppStyles.headingMd.copyWith(color: color)),
        ],
      ),
    );
  }

  // Charts Section
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inventory Analytics Charts', style: AppStyles.headingMd),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          spacing: AppStyles.space4,
          children: [
            _buildStockLevelChart(),
            _buildCategoryDistributionChart(),
            _buildStockStatusChart(),
            _buildReorderPriorityChart(),
          ],
        ),
      ],
    );
  }

  Widget _buildStockLevelChart() {
    if (_inventory.isEmpty) {
      return _buildEmptyChart('Stock Level', 'No inventory data available');
    }

    // Sort inventory by quantity
    final sortedInventory = List<InventoryModel>.from(_inventory)
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return AppCard(
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
                  Icons.bar_chart,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Text('Stock Level by Product', style: AppStyles.labelLg),
            ],
          ),
          const SizedBox(height: AppStyles.space4),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedInventory.isNotEmpty
                    ? sortedInventory.first.quantity * 1.2
                    : 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < sortedInventory.length) {
                          final item = sortedInventory[value.toInt()];
                          return Text(
                            item.productName.length > 8
                                ? '${item.productName.substring(0, 8)}...'
                                : item.productName,
                            style: AppStyles.bodyXs,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
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
                borderData: FlBorderData(show: true),
                barGroups: sortedInventory.asMap().entries.map((entry) {
                  final item = entry.value;
                  Color barColor = AppColors.success;
                  if (item.quantity < item.minimumThreshold) {
                    barColor = AppColors.warning;
                  }
                  if (item.quantity == 0) {
                    barColor = AppColors.error;
                  }

                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: item.quantity,
                        color: barColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart() {
    if (_inventory.isEmpty) {
      return _buildEmptyChart(
        'Category Distribution',
        'No inventory data available',
      );
    }

    final categoryCounts = <String, int>{};
    for (final item in _inventory) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
    }

    final colors = [
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
      AppColors.primary,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Text('Category Distribution', style: AppStyles.labelLg),
            ],
          ),
          const SizedBox(height: AppStyles.space4),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: categoryCounts.entries.map((entry) {
                        final index = categoryCounts.keys.toList().indexOf(
                          entry.key,
                        );
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${entry.value}',
                          color: colors[index % colors.length],
                          radius: 60,
                          titleStyle: AppStyles.bodySm.copyWith(
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryCounts.entries.map((entry) {
                      final index = categoryCounts.keys.toList().indexOf(
                        entry.key,
                      );
                      return _buildLegendItemNew(
                        entry.key.length > 12
                            ? '${entry.key.substring(0, 12)}...'
                            : entry.key,
                        colors[index % colors.length],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatusChart() {
    if (_inventory.isEmpty) {
      return _buildEmptyChart('Stock Status', 'No inventory data available');
    }

    final healthyCount = _inventory
        .where((item) => item.quantity >= item.minimumThreshold)
        .length;
    final lowStockCount = _inventory
        .where(
          (item) => item.quantity < item.minimumThreshold && item.quantity > 0,
        )
        .length;
    final outOfStockCount = _inventory
        .where((item) => item.quantity == 0)
        .length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                ),
                child: const Icon(
                  Icons.donut_large,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Text('Stock Status Overview', style: AppStyles.labelLg),
            ],
          ),
          const SizedBox(height: AppStyles.space4),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: healthyCount.toDouble(),
                          title: '$healthyCount',
                          color: AppColors.success,
                          radius: 60,
                          titleStyle: AppStyles.bodySm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: lowStockCount.toDouble(),
                          title: '$lowStockCount',
                          color: AppColors.warning,
                          radius: 60,
                          titleStyle: AppStyles.bodySm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: outOfStockCount.toDouble(),
                          title: '$outOfStockCount',
                          color: AppColors.error,
                          radius: 60,
                          titleStyle: AppStyles.bodySm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItemNew('Healthy', AppColors.success),
                      _buildLegendItemNew('Low Stock', AppColors.warning),
                      _buildLegendItemNew('Out of Stock', AppColors.error),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderPriorityChart() {
    if (_inventory.isEmpty) {
      return _buildEmptyChart(
        'Reorder Priority',
        'No inventory data available',
      );
    }

    // Get items that need reordering
    final reorderItems =
        _inventory
            .where((item) => item.quantity <= item.minimumThreshold)
            .toList()
          ..sort((a, b) => a.quantity.compareTo(b.quantity));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                ),
                child: const Icon(
                  Icons.priority_high,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Text('Reorder Priority', style: AppStyles.labelLg),
            ],
          ),
          const SizedBox(height: AppStyles.space4),
          SizedBox(
            height: 200,
            child: reorderItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items need reordering',
                      style: AppStyles.bodySm,
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: reorderItems.isNotEmpty
                          ? reorderItems.first.minimumThreshold * 1.5
                          : 100,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < reorderItems.length) {
                                final item = reorderItems[value.toInt()];
                                return Text(
                                  item.productName.length > 8
                                      ? '${item.productName.substring(0, 8)}...'
                                      : item.productName,
                                  style: AppStyles.bodyXs,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
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
                      borderData: FlBorderData(show: true),
                      barGroups: reorderItems.asMap().entries.map((entry) {
                        final item = entry.value;
                        Color barColor = AppColors.warning;
                        if (item.quantity == 0) {
                          barColor = AppColors.error;
                        }

                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: item.quantity,
                              color: barColor,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Predictive Analysis
  Widget _buildPredictiveAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Predictive Analysis', style: AppStyles.headingMd),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 1,
          desktopColumns: 3,
          spacing: AppStyles.space4,
          children: [
            _buildPredictionCard(
              'Restock Forecast',
              _predictRestockNeeds(),
              Icons.inventory,
              AppColors.warning,
            ),
            _buildPredictionCard(
              'Inventory Optimization',
              _predictInventoryOptimization(),
              Icons.assessment,
              AppColors.success,
            ),
            _buildPredictionCard(
              'Turnover Rate',
              _predictTurnoverRate(),
              Icons.trending_up,
              AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPredictionCard(
    String title,
    String prediction,
    IconData icon,
    Color color,
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppStyles.space2),
                Expanded(child: Text(title, style: AppStyles.labelLg)),
              ],
            ),
            const SizedBox(height: AppStyles.space3),
            Text(
              prediction,
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _predictRestockNeeds() {
    if (_inventory.isEmpty) return 'No data available';

    final lowStockItems = _inventory
        .where((item) => item.quantity <= item.minimumThreshold)
        .length;
    final totalItems = _inventory.length;
    final percentage = (lowStockItems / totalItems * 100).toInt();

    return '${lowStockItems} items need restocking\n($percentage% of inventory)\nPlan procurement accordingly';
  }

  String _predictInventoryOptimization() {
    if (_inventory.isEmpty) return 'No data available';

    final overstockedItems = _inventory
        .where((item) => item.quantity > item.minimumThreshold * 3)
        .length;

    if (overstockedItems > 0) {
      return '${overstockedItems} items overstocked\nConsider reducing orders\nOptimize storage space';
    }

    return 'Inventory levels optimal\nMaintain current strategy\nMonitor stock movements';
  }

  String _predictTurnoverRate() {
    if (_inventory.isEmpty) return 'No data available';

    final avgStock =
        _inventory.fold<double>(0, (sum, item) => sum + item.quantity) /
        _inventory.length;
    final avgThreshold =
        _inventory.fold<double>(0, (sum, item) => sum + item.minimumThreshold) /
        _inventory.length;

    if (avgStock > avgThreshold * 2) {
      return 'Slow-moving inventory\nConsider promotions\nReview product mix';
    } else if (avgStock < avgThreshold) {
      return 'Fast-moving inventory\nIncrease stock levels\nMonitor demand patterns';
    }

    return 'Balanced inventory turnover\nMaintain current levels\nTrack seasonal trends';
  }

  Widget _buildLegendItemNew(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.space2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppStyles.space2),
          Expanded(
            child: Text(
              label,
              style: AppStyles.bodyXs,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, String message) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppStyles.space2),
          Text(title, style: AppStyles.labelMd),
          const SizedBox(height: AppStyles.space1),
          Text(
            message,
            style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
