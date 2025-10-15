import 'package:flutter/material.dart';
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
}
