import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../utils/export_utils.dart';
import '../../models/production_model.dart';
import '../../models/product_model.dart';
import '../../services/production_service.dart';
import '../../services/product_service.dart';

class ProductionReportScreen extends StatefulWidget {
  const ProductionReportScreen({Key? key}) : super(key: key);

  @override
  State<ProductionReportScreen> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen> {
  List<Production> _productions = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadProductions();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.getAll();
      setState(() => _products = products);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadProductions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Production> data;

      if (_selectedProductId != null) {
        data = await ProductionService.getByProduct(_selectedProductId!);
      } else if (_startDate != null && _endDate != null) {
        data = await ProductionService.getByDateRange(
          DateFormat('yyyy-MM-dd').format(_startDate!),
          DateFormat('yyyy-MM-dd').format(_endDate!),
        );
      } else {
        data = await ProductionService.getAll();
      }

      setState(() {
        _productions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedProductId = null; // Clear product filter
      });
      _loadProductions();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedProductId = null;
    });
    _loadProductions();
  }

  Future<void> _showExportOptions() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('Export as PDF'),
              subtitle: const Text('Formatted report with metrics'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ExportUtils.exportProductionToPDF(_productions);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF exported successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('Export as Excel/CSV'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final path = await ExportUtils.exportProductionToCSV(
                    _productions,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('CSV exported to: $path'),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're inside a Scaffold already (AdminLayout)
    final hasScaffold = Scaffold.maybeOf(context) != null;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters', style: AppStyles.labelLg),
              const SizedBox(height: AppStyles.space4),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: _startDate == null
                          ? 'Select Date Range'
                          : '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}',
                      icon: Icons.date_range,
                      onPressed: _selectDateRange,
                      variant: ButtonVariant.outline,
                      size: ButtonSize.sm,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space2),
                  if (_startDate != null || _selectedProductId != null)
                    AppIconButton(
                      icon: Icons.clear,
                      onPressed: _clearFilters,
                      tooltip: 'Clear filters',
                    ),
                ],
              ),
              if (_products.isNotEmpty) ...[
                const SizedBox(height: AppStyles.space3),
                DropdownButtonFormField<int>(
                  value: _selectedProductId,
                  decoration: AppStyles.inputDecoration(
                    label: 'Filter by Product',
                    prefixIcon: Icons.category,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Products'),
                    ),
                    ..._products.map(
                      (product) => DropdownMenuItem(
                        value: product.productId,
                        child: Text(product.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                      _startDate = null;
                      _endDate = null;
                    });
                    _loadProductions();
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppStyles.space6),

        // Content
        if (_isLoading)
          const SizedBox(
            height: 300,
            child: AppLoadingState(message: 'Loading production data...'),
          )
        else if (_error != null)
          SizedBox(
            height: 300,
            child: AppErrorState(
              title: 'Failed to load data',
              subtitle: _error,
              onRetry: _loadProductions,
            ),
          )
        else if (_productions.isEmpty)
          const SizedBox(
            height: 300,
            child: AppEmptyState(
              icon: Icons.factory,
              title: 'No production data',
              subtitle: 'No production logs found for the selected filters',
            ),
          )
        else
          _buildProductionList(),
      ],
    );

    // If inside AdminLayout, just return scrollable content
    if (hasScaffold) {
      return RefreshIndicator(
        onRefresh: _loadProductions,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.space4),
          child: content,
        ),
      );
    }

    // Otherwise, use full scaffold (for Manager drawer navigation)
    return ScrollableAppScaffold(
      title: 'Production Report',
      onRefresh: _loadProductions,
      useResponsiveContainer: false,
      actions: _productions.isNotEmpty
          ? [
              AppIconButton(
                icon: Icons.file_download,
                onPressed: () => _showExportOptions(),
                tooltip: 'Export Report',
              ),
              const SizedBox(width: AppStyles.space2),
            ]
          : null,
      child: content,
    );
  }

  Widget _buildProductionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Analytics Section
        _buildAnalyticsSection(),
        const SizedBox(height: AppStyles.space6),

        // Charts Section
        _buildChartsSection(),
        const SizedBox(height: AppStyles.space6),

        // Predictive Analysis
        _buildPredictiveAnalysis(),
        const SizedBox(height: AppStyles.space6),

        // Production Logs
        Text(
          'Production Logs (${_productions.length})',
          style: AppStyles.headingSm,
        ),
        const SizedBox(height: AppStyles.space4),
        ...List.generate(_productions.length, (index) {
          final production = _productions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppStyles.space3),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          production.productName ?? 'Unknown Product',
                          style: AppStyles.labelLg,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(DateTime.parse(production.date)),
                        style: AppStyles.bodySm,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.space2),
                  Text(
                    'Supervisor: ${production.supervisorName ?? 'Unknown'}',
                    style: AppStyles.bodySm,
                  ),
                  const SizedBox(height: AppStyles.space3),
                  ResponsiveLayout(
                    mobile: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetric(
                          'Input',
                          '${production.inputQty} kg',
                          Icons.arrow_downward,
                          AppColors.info,
                        ),
                        const SizedBox(height: AppStyles.space2),
                        _buildMetric(
                          'Output',
                          '${production.outputQty} kg',
                          Icons.arrow_upward,
                          AppColors.success,
                        ),
                        const SizedBox(height: AppStyles.space2),
                        _buildMetric(
                          'Efficiency',
                          '${production.efficiency.toStringAsFixed(1)}%',
                          Icons.trending_up,
                          AppColors.primary,
                        ),
                      ],
                    ),
                    tablet: Row(
                      children: [
                        Expanded(
                          child: _buildMetric(
                            'Input',
                            '${production.inputQty} kg',
                            Icons.arrow_downward,
                            AppColors.info,
                          ),
                        ),
                        Expanded(
                          child: _buildMetric(
                            'Output',
                            '${production.outputQty} kg',
                            Icons.arrow_upward,
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _buildMetric(
                            'Efficiency',
                            '${production.efficiency.toStringAsFixed(1)}%',
                            Icons.trending_up,
                            AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (production.notes != null) ...[
                    const SizedBox(height: AppStyles.space3),
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space2),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                      ),
                      child: Text(production.notes!, style: AppStyles.bodyXs),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppStyles.bodyXs),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: AppStyles.labelMd.copyWith(color: color)),
      ],
    );
  }

  // Analytics Section
  Widget _buildAnalyticsSection() {
    final totalInput = _productions.fold<double>(
      0,
      (sum, p) => sum + p.inputQty,
    );
    final totalOutput = _productions.fold<double>(
      0,
      (sum, p) => sum + p.outputQty,
    );
    final avgEfficiency = _productions.isEmpty
        ? 0.0
        : _productions.fold<double>(0, (sum, p) => sum + p.efficiency) /
              _productions.length;
    final bestEfficiency = _productions.isEmpty
        ? 0.0
        : _productions.map((p) => p.efficiency).reduce(max);
    final worstEfficiency = _productions.isEmpty
        ? 0.0
        : _productions.map((p) => p.efficiency).reduce(min);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Production Analytics', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 4,
          desktopColumns: 6,
          spacing: AppStyles.space3,
          children: [
            _buildAnalyticsCard(
              'Total Input',
              '${totalInput.toStringAsFixed(0)} kg',
              Icons.arrow_downward,
              AppColors.info,
            ),
            _buildAnalyticsCard(
              'Total Output',
              '${totalOutput.toStringAsFixed(0)} kg',
              Icons.arrow_upward,
              AppColors.success,
            ),
            _buildAnalyticsCard(
              'Avg Efficiency',
              '${avgEfficiency.toStringAsFixed(1)}%',
              Icons.trending_up,
              avgEfficiency >= 80 ? AppColors.success : AppColors.warning,
            ),
            _buildAnalyticsCard(
              'Best Efficiency',
              '${bestEfficiency.toStringAsFixed(1)}%',
              Icons.star,
              AppColors.success,
            ),
            _buildAnalyticsCard(
              'Worst Efficiency',
              '${worstEfficiency.toStringAsFixed(1)}%',
              Icons.trending_down,
              worstEfficiency < 70 ? AppColors.error : AppColors.warning,
            ),
            _buildAnalyticsCard(
              'Production Runs',
              '${_productions.length}',
              Icons.factory,
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

  // Charts Section
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Production Charts', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          spacing: AppStyles.space4,
          children: [
            _buildEfficiencyTrendChart(),
            _buildProductionVolumeChart(),
            _buildProductDistributionChart(),
            _buildMonthlyProductionChart(),
          ],
        ),
      ],
    );
  }

  Widget _buildEfficiencyTrendChart() {
    if (_productions.isEmpty) {
      return _buildEmptyChart(
        'Efficiency Trend',
        'No production data available',
      );
    }

    // Group by date and calculate average efficiency
    final Map<String, List<Production>> groupedByDate = {};
    for (final production in _productions) {
      final date = production.date.split(' ')[0]; // Get date part only
      groupedByDate.putIfAbsent(date, () => []).add(production);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final productions = groupedByDate[date]!;
      final avgEfficiency =
          productions.fold<double>(0, (sum, p) => sum + p.efficiency) /
          productions.length;
      spots.add(FlSpot(i.toDouble(), avgEfficiency));
    }

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
                Text('Efficiency Trend', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: AppStyles.bodyXs,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()];
                            return Text(
                              DateFormat('MMM dd').format(DateTime.parse(date)),
                              style: AppStyles.bodyXs,
                            );
                          }
                          return const Text('');
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.success,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.success.withOpacity(0.1),
                      ),
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

  Widget _buildProductionVolumeChart() {
    if (_productions.isEmpty) {
      return _buildEmptyChart(
        'Production Volume',
        'No production data available',
      );
    }

    // Group by product
    final Map<String, double> productOutputs = {};
    for (final production in _productions) {
      final productName = production.productName ?? 'Unknown';
      productOutputs[productName] =
          (productOutputs[productName] ?? 0) + production.outputQty;
    }

    final sortedProducts = productOutputs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                    Icons.bar_chart,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Production Volume by Product', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: sortedProducts.isNotEmpty
                      ? sortedProducts.first.value * 1.2
                      : 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}kg',
                            style: AppStyles.bodyXs,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedProducts.length) {
                            final product = sortedProducts[value.toInt()];
                            return Text(
                              product.key.length > 8
                                  ? '${product.key.substring(0, 8)}...'
                                  : product.key,
                              style: AppStyles.bodyXs,
                            );
                          }
                          return const Text('');
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
                  barGroups: sortedProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: product.value,
                          color: AppColors.primary,
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
      ),
    );
  }

  Widget _buildProductDistributionChart() {
    if (_productions.isEmpty) {
      return _buildEmptyChart(
        'Product Distribution',
        'No production data available',
      );
    }

    // Count productions by product
    final Map<String, int> productCounts = {};
    for (final production in _productions) {
      final productName = production.productName ?? 'Unknown';
      productCounts[productName] = (productCounts[productName] ?? 0) + 1;
    }

    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
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
                Text('Product Distribution', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: productCounts.entries.map((entry) {
                    final index = productCounts.keys.toList().indexOf(
                      entry.key,
                    );
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: colors[index % colors.length],
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space4),
            Wrap(
              spacing: AppStyles.space3,
              runSpacing: AppStyles.space2,
              children: productCounts.entries.map((entry) {
                final index = productCounts.keys.toList().indexOf(entry.key);
                return _buildLegendItem(
                  entry.key.length > 12
                      ? '${entry.key.substring(0, 12)}...'
                      : entry.key,
                  colors[index % colors.length],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProductionChart() {
    if (_productions.isEmpty) {
      return _buildEmptyChart(
        'Monthly Production',
        'No production data available',
      );
    }

    // Group by month
    final Map<String, double> monthlyOutput = {};
    for (final production in _productions) {
      final date = DateTime.parse(production.date);
      final monthKey = DateFormat('yyyy-MM').format(date);
      monthlyOutput[monthKey] =
          (monthlyOutput[monthKey] ?? 0) + production.outputQty;
    }

    final sortedMonths = monthlyOutput.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      spots.add(FlSpot(i.toDouble(), monthlyOutput[month]!));
    }

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
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Monthly Production Trend', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}kg',
                            style: AppStyles.bodyXs,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedMonths.length) {
                            final month = sortedMonths[value.toInt()];
                            return Text(
                              DateFormat(
                                'MMM yyyy',
                              ).format(DateTime.parse('$month-01')),
                              style: AppStyles.bodyXs,
                            );
                          }
                          return const Text('');
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.info,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.info.withOpacity(0.1),
                      ),
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

  // Predictive Analysis Section
  Widget _buildPredictiveAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Predictive Analysis', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: AppStyles.space4,
          children: [
            _buildPredictionCard(
              'Next Month Forecast',
              _predictNextMonthOutput(),
              Icons.trending_up,
              AppColors.success,
            ),
            _buildPredictionCard(
              'Efficiency Forecast',
              _predictEfficiencyTrend(),
              Icons.analytics,
              AppColors.primary,
            ),
            _buildPredictionCard(
              'Resource Planning',
              _predictResourceNeeds(),
              Icons.inventory,
              AppColors.warning,
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
            const SizedBox(height: AppStyles.space4),
            Text(
              prediction,
              style: AppStyles.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _predictNextMonthOutput() {
    if (_productions.length < 2) return 'Insufficient data for prediction';

    final recentOutputs = _productions.take(5).map((p) => p.outputQty).toList();
    final avgOutput =
        recentOutputs.fold<double>(0, (sum, output) => sum + output) /
        recentOutputs.length;
    final predictedOutput = avgOutput * 1.1; // 10% growth assumption

    return 'Predicted output: ${predictedOutput.toStringAsFixed(0)} kg\nBased on recent trends';
  }

  String _predictEfficiencyTrend() {
    if (_productions.length < 3) return 'Need more data for analysis';

    final recentEfficiencies = _productions
        .take(5)
        .map((p) => p.efficiency)
        .toList();
    final avgEfficiency =
        recentEfficiencies.fold<double>(0, (sum, eff) => sum + eff) /
        recentEfficiencies.length;

    if (avgEfficiency >= 85) {
      return 'Excellent efficiency trend\nMaintain current practices';
    } else if (avgEfficiency >= 75) {
      return 'Good efficiency trend\nConsider minor optimizations';
    } else {
      return 'Efficiency needs improvement\nReview production processes';
    }
  }

  String _predictResourceNeeds() {
    if (_productions.isEmpty) return 'No data available';

    final totalInput = _productions.fold<double>(
      0,
      (sum, p) => sum + p.inputQty,
    );
    final avgInput = totalInput / _productions.length;
    final predictedInput = avgInput * 1.15; // 15% increase assumption

    return 'Predicted material needs:\n${predictedInput.toStringAsFixed(0)} kg\nPlan procurement accordingly';
  }

  Widget _buildEmptyChart(String title, String message) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.space4),
        child: Column(
          children: [
            Text(title, style: AppStyles.labelLg),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: AppColors.gray400),
                    const SizedBox(height: AppStyles.space2),
                    Text(
                      message,
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
