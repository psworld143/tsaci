import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../utils/export_utils.dart';
import '../../models/sales_model.dart';
import '../../services/sales_service.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({Key? key}) : super(key: key);

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final SalesService _salesService = SalesService();
  List<SalesModel> _sales = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sales = await _salesService.getAllSales();

      // Apply filters
      List<SalesModel> filteredSales = sales;

      if (_startDate != null && _endDate != null) {
        filteredSales = filteredSales.where((sale) {
          return sale.date.isAfter(
                _startDate!.subtract(const Duration(days: 1)),
              ) &&
              sale.date.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      }

      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        filteredSales = filteredSales.where((sale) {
          return sale.status.toLowerCase() == _selectedStatus!.toLowerCase();
        }).toList();
      }

      setState(() {
        _sales = filteredSales;
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
      });
      _loadSales();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedStatus = null;
    });
    _loadSales();
  }

  Map<String, double> _getProductBreakdown() {
    final Map<String, double> breakdown = {};
    for (var sale in _sales) {
      breakdown[sale.productName] =
          (breakdown[sale.productName] ?? 0) + sale.totalAmount;
    }
    return breakdown;
  }

  Map<String, int> _getStatusBreakdown() {
    final Map<String, int> breakdown = {};
    for (var sale in _sales) {
      breakdown[sale.status] = (breakdown[sale.status] ?? 0) + 1;
    }
    return breakdown;
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
              subtitle: const Text('Formatted report with charts'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ExportUtils.exportSalesToPDF(_sales);
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
                  final path = await ExportUtils.exportSalesToCSV(_sales);
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
                  if (_startDate != null || _selectedStatus != null)
                    AppIconButton(
                      icon: Icons.clear,
                      onPressed: _clearFilters,
                      tooltip: 'Clear filters',
                    ),
                ],
              ),
              const SizedBox(height: AppStyles.space3),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: AppStyles.inputDecoration(
                  label: 'Filter by Status',
                  prefixIcon: Icons.filter_list,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  _loadSales();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppStyles.space6),

        // Content
        if (_isLoading)
          const SizedBox(
            height: 300,
            child: AppLoadingState(message: 'Loading sales data...'),
          )
        else if (_error != null)
          SizedBox(
            height: 300,
            child: AppErrorState(
              title: 'Failed to load data',
              subtitle: _error,
              onRetry: _loadSales,
            ),
          )
        else if (_sales.isEmpty)
          const SizedBox(
            height: 300,
            child: AppEmptyState(
              icon: Icons.point_of_sale,
              title: 'No sales data',
              subtitle: 'No sales found for the selected filters',
            ),
          )
        else
          _buildSalesReport(),

        // Analytics Section
        if (!_isLoading && _error == null && _sales.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildAnalyticsSection(),
        ],

        // Charts Section
        if (!_isLoading && _error == null && _sales.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildChartsSection(),
        ],

        // Predictive Analysis
        if (!_isLoading && _error == null && _sales.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildPredictiveAnalysis(),
        ],
      ],
    );

    // If inside AdminLayout, just return scrollable content
    if (hasScaffold) {
      return RefreshIndicator(
        onRefresh: _loadSales,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.space4),
          child: content,
        ),
      );
    }

    // Otherwise, use full scaffold (for Manager drawer navigation)
    return ScrollableAppScaffold(
      title: 'Sales Report',
      onRefresh: _loadSales,
      useResponsiveContainer: false,
      actions: _sales.isNotEmpty
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

  Widget _buildSalesReport() {
    final totalRevenue = _sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );
    final totalQuantity = _sales.fold<int>(
      0,
      (sum, sale) => sum + sale.quantity,
    );
    final productBreakdown = _getProductBreakdown();
    final statusBreakdown = _getStatusBreakdown();

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
              title: 'Total Revenue',
              value: '₱${totalRevenue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
            StatCard(
              title: 'Orders',
              value: '${_sales.length}',
              icon: Icons.shopping_cart,
              color: AppColors.info,
            ),
            StatCard(
              title: 'Units Sold',
              value: '$totalQuantity',
              icon: Icons.inventory,
              color: AppColors.primary,
            ),
            StatCard(
              title: 'Avg Order',
              value: '₱${(totalRevenue / _sales.length).toStringAsFixed(2)}',
              icon: Icons.analytics,
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space6),

        // Status Breakdown
        Text('Order Status Breakdown', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 3,
          desktopColumns: 3,
          spacing: AppStyles.space3,
          children: statusBreakdown.entries.map((entry) {
            return AppCard(
              child: Column(
                children: [
                  AppBadge(
                    text: entry.key.toUpperCase(),
                    variant: _getStatusBadgeVariant(entry.key),
                  ),
                  const SizedBox(height: AppStyles.space2),
                  Text('${entry.value}', style: AppStyles.headingLg),
                  Text(
                    'Orders',
                    style: AppStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppStyles.space6),

        // Product Revenue Breakdown
        Text('Top Selling Products', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        AppCard(
          child: Column(
            children: () {
              final sortedProducts = productBreakdown.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              return sortedProducts.take(10).map((entry) {
                final percentage = (entry.value / totalRevenue * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppStyles.space3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: AppStyles.labelMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppStyles.space2),
                          Text(
                            '₱${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                            style: AppStyles.labelMd.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.space2),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.gray200,
                        color: AppColors.success,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }).toList();
            }(),
          ),
        ),
        const SizedBox(height: AppStyles.space6),

        // Sales List
        Text(
          'Sales Details (${_sales.length} items)',
          style: AppStyles.headingSm,
        ),
        const SizedBox(height: AppStyles.space4),
        ...List.generate(_sales.length, (index) {
          final sale = _sales[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppStyles.space3),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sale.productName, style: AppStyles.labelLg),
                            const SizedBox(height: AppStyles.space1),
                            Text(
                              sale.customerName,
                              style: AppStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppBadge(
                        text: sale.status.toUpperCase(),
                        variant: _getStatusBadgeVariant(sale.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.space3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: AppStyles.labelSm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${sale.quantity} units',
                            style: AppStyles.bodySm,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppStyles.labelSm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '₱${sale.totalAmount.toStringAsFixed(2)}',
                            style: AppStyles.headingSm.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.space2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppStyles.space1),
                      Text(
                        DateFormat('MMM d, y').format(sale.date),
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

  BadgeVariant _getStatusBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return BadgeVariant.success;
      case 'pending':
        return BadgeVariant.warning;
      case 'cancelled':
        return BadgeVariant.danger;
      default:
        return BadgeVariant.info;
    }
  }

  // Analytics Section
  Widget _buildAnalyticsSection() {
    final totalRevenue = _sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );
    final totalTransactions = _sales.length;
    final avgOrderValue = totalTransactions > 0
        ? totalRevenue / totalTransactions
        : 0.0;

    // Top product by quantity
    final productQuantities = <String, int>{};
    for (final sale in _sales) {
      productQuantities[sale.productName] =
          (productQuantities[sale.productName] ?? 0) + sale.quantity;
    }
    final topProduct = productQuantities.entries.isNotEmpty
        ? productQuantities.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
        : 'N/A';

    final completedSales = _sales
        .where((s) => s.status.toLowerCase() == 'completed')
        .length;
    final pendingSales = _sales
        .where((s) => s.status.toLowerCase() == 'pending')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sales Analytics', style: AppStyles.headingMd),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: AppStyles.space4,
          children: [
            _buildAnalyticsCard(
              'Total Revenue',
              '₱${totalRevenue.toStringAsFixed(2)}',
              Icons.attach_money,
              AppColors.success,
            ),
            _buildAnalyticsCard(
              'Total Transactions',
              totalTransactions.toString(),
              Icons.shopping_cart,
              AppColors.info,
            ),
            _buildAnalyticsCard(
              'Average Order Value',
              '₱${avgOrderValue.toStringAsFixed(2)}',
              Icons.analytics,
              AppColors.primary,
            ),
            _buildAnalyticsCard(
              'Top Product',
              topProduct.length > 15
                  ? '${topProduct.substring(0, 15)}...'
                  : topProduct,
              Icons.star,
              AppColors.warning,
            ),
            _buildAnalyticsCard(
              'Completed Sales',
              completedSales.toString(),
              Icons.check_circle,
              AppColors.success,
            ),
            _buildAnalyticsCard(
              'Pending Sales',
              pendingSales.toString(),
              Icons.pending,
              AppColors.warning,
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
        Text('Sales Analytics Charts', style: AppStyles.headingMd),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          spacing: AppStyles.space4,
          children: [
            _buildRevenueTrendChart(),
            _buildSalesByProductChart(),
            _buildSalesStatusChart(),
            _buildMonthlyRevenueChart(),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueTrendChart() {
    if (_sales.isEmpty) {
      return _buildEmptyChart('Revenue Trend', 'No sales data available');
    }

    // Group sales by date
    final Map<String, List<SalesModel>> groupedByDate = {};
    for (final sale in _sales) {
      final dateKey = DateFormat('yyyy-MM-dd').format(sale.date);
      groupedByDate[dateKey] = (groupedByDate[dateKey] ?? [])..add(sale);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final sales = groupedByDate[date]!;
      final dailyRevenue = sales.fold<double>(
        0,
        (sum, sale) => sum + sale.totalAmount,
      );
      spots.add(FlSpot(i.toDouble(), dailyRevenue));
    }

    return AppCard(
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
              Text('Revenue Trend', style: AppStyles.labelLg),
            ],
          ),
          const SizedBox(height: AppStyles.space4),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < sortedDates.length) {
                          final date = DateTime.parse(
                            sortedDates[value.toInt()],
                          );
                          return Text(
                            DateFormat('MMM dd').format(date),
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
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
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
    );
  }

  Widget _buildSalesByProductChart() {
    if (_sales.isEmpty) {
      return _buildEmptyChart('Sales by Product', 'No sales data available');
    }

    // Group sales by product
    final Map<String, int> productSales = {};
    for (final sale in _sales) {
      productSales[sale.productName] =
          (productSales[sale.productName] ?? 0) + sale.quantity;
    }

    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
              Text('Sales by Product', style: AppStyles.labelLg),
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
                barGroups: sortedProducts.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
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
    );
  }

  Widget _buildSalesStatusChart() {
    if (_sales.isEmpty) {
      return _buildEmptyChart('Sales Status', 'No sales data available');
    }

    final statusCounts = <String, int>{};
    for (final sale in _sales) {
      statusCounts[sale.status] = (statusCounts[sale.status] ?? 0) + 1;
    }

    final colors = [
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
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
              Text('Sales Status Distribution', style: AppStyles.labelLg),
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
                      sections: statusCounts.entries.map((entry) {
                        final index = statusCounts.keys.toList().indexOf(
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
                    children: statusCounts.entries.map((entry) {
                      final index = statusCounts.keys.toList().indexOf(
                        entry.key,
                      );
                      return _buildLegendItem(
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

  Widget _buildMonthlyRevenueChart() {
    if (_sales.isEmpty) {
      return _buildEmptyChart('Monthly Revenue', 'No sales data available');
    }

    // Group sales by month
    final Map<String, double> monthlyRevenue = {};
    for (final sale in _sales) {
      final monthKey = DateFormat('yyyy-MM').format(sale.date);
      monthlyRevenue[monthKey] =
          (monthlyRevenue[monthKey] ?? 0) + sale.totalAmount;
    }

    final sortedMonths = monthlyRevenue.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final revenue = monthlyRevenue[month]!;
      spots.add(FlSpot(i.toDouble(), revenue));
    }

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
                  Icons.calendar_month,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Text('Monthly Revenue Trend', style: AppStyles.labelLg),
            ],
          ),
          const SizedBox(height: AppStyles.space4),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₱${(value / 1000).toInt()}k',
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
              'Next Month Revenue Forecast',
              _predictNextMonthRevenue(),
              Icons.trending_up,
              AppColors.success,
            ),
            _buildPredictionCard(
              'Sales Trend Analysis',
              _predictSalesTrend(),
              Icons.analytics,
              AppColors.primary,
            ),
            _buildPredictionCard(
              'Customer Demand Forecast',
              _predictCustomerDemand(),
              Icons.people,
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

  String _predictNextMonthRevenue() {
    if (_sales.length < 2) return 'Insufficient data for prediction';

    final recentRevenue = _sales.take(5).map((s) => s.totalAmount).toList();
    final avgRevenue =
        recentRevenue.fold<double>(0, (sum, revenue) => sum + revenue) /
        recentRevenue.length;
    final predictedRevenue = avgRevenue * 1.08; // 8% growth assumption

    return 'Predicted revenue: ₱${predictedRevenue.toStringAsFixed(2)}\nBased on recent trends';
  }

  String _predictSalesTrend() {
    if (_sales.length < 3) return 'Need more data for analysis';

    final recentSales = _sales.take(5).map((s) => s.totalAmount).toList();
    final avgSales =
        recentSales.fold<double>(0, (sum, sale) => sum + sale) /
        recentSales.length;

    if (avgSales >= 1000) {
      return 'Strong sales trend\nMaintain current strategies';
    } else if (avgSales >= 500) {
      return 'Moderate sales trend\nConsider marketing boost';
    } else {
      return 'Weak sales trend\nReview sales strategy';
    }
  }

  String _predictCustomerDemand() {
    if (_sales.isEmpty) return 'No data available';

    final productCounts = <String, int>{};
    for (final sale in _sales) {
      productCounts[sale.productName] =
          (productCounts[sale.productName] ?? 0) + 1;
    }

    final topProducts = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topProducts.isNotEmpty) {
      return 'Top demand: ${topProducts.first.key}\nFocus on popular products';
    }

    return 'Analyze product performance\nIdentify growth opportunities';
  }

  Widget _buildLegendItem(String label, Color color) {
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
