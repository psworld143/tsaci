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
            _buildCategoryDistributionChart(categoryDistribution),
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

  Widget _buildCategoryDistributionChart(Map<String, int> distribution) {
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
}
