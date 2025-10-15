import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        Text(
          '${_productions.length} Production Logs',
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
}
