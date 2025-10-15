import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../utils/export_utils.dart';
import '../../models/production_model.dart';
import '../../models/production_batch_model.dart';
import '../../models/product_model.dart';
import '../../models/worker_progress_model.dart';
import '../../services/production_service.dart';
import '../../services/batch_service.dart';
import '../../services/product_service.dart';
import '../../services/worker_supervision_service.dart';

class ProductionReportsScreen extends StatefulWidget {
  const ProductionReportsScreen({Key? key}) : super(key: key);

  @override
  State<ProductionReportsScreen> createState() =>
      _ProductionReportsScreenState();
}

class _ProductionReportsScreenState extends State<ProductionReportsScreen> {
  List<Production> _productions = [];
  List<ProductionBatch> _batches = [];
  List<ProductModel> _products = [];
  List<WorkerProgress> _workerProgress = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedBatchId;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('[ProductionReports] Loading data...');

      // Load productions (non-critical)
      List<Production> productions = [];
      try {
        productions = await ProductionService.getAll();
        print('[ProductionReports] Productions loaded: ${productions.length}');
      } catch (e) {
        print('[ProductionReports] Productions error (non-critical): $e');
        // Continue without production logs
      }

      // Load batches
      print('[ProductionReports] Loading batches...');
      final batches = await BatchService.getAllBatches();
      print('[ProductionReports] Batches loaded: ${batches.length}');

      // Load products (non-critical)
      List<ProductModel> products = [];
      try {
        products = await ProductService.getAll();
        print('[ProductionReports] Products loaded: ${products.length}');
      } catch (e) {
        print('[ProductionReports] Products error (non-critical): $e');
      }

      // Load worker progress
      List<WorkerProgress> workerProgress = [];
      try {
        workerProgress = await WorkerSupervisionService.getAllProgress();
        print(
          '[ProductionReports] Worker progress loaded: ${workerProgress.length}',
        );
      } catch (e) {
        print('[ProductionReports] Worker progress error (non-critical): $e');
      }

      setState(() {
        _productions = productions;
        _batches = batches;
        _products = products;
        _workerProgress = workerProgress;
        _isLoading = false;
      });

      print('[ProductionReports] Data loading complete');
      print('  - Productions: ${productions.length}');
      print('  - Batches: ${batches.length}');
      print('  - Products: ${products.length}');
      print('  - Worker Progress: ${workerProgress.length}');
    } catch (e) {
      print('[ProductionReports] Critical error: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Production> get _filteredProductions {
    var filtered = _productions;

    if (_startDate != null) {
      filtered = filtered.where((p) {
        final date = DateTime.parse(p.date);
        return date.isAfter(_startDate!.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((p) {
        final date = DateTime.parse(p.date);
        return date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (_selectedProductId != null) {
      filtered = filtered
          .where((p) => p.productId == _selectedProductId)
          .toList();
    }

    return filtered;
  }

  List<ProductionBatch> get _filteredBatches {
    var filtered = _batches;

    if (_startDate != null) {
      filtered = filtered.where((b) {
        return b.scheduledDate.isAfter(
          _startDate!.subtract(const Duration(days: 1)),
        );
      }).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((b) {
        return b.scheduledDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (_selectedProductId != null) {
      filtered = filtered
          .where((b) => b.productId == _selectedProductId)
          .toList();
    }

    if (_selectedBatchId != null) {
      filtered = filtered.where((b) => b.batchId == _selectedBatchId).toList();
    }

    return filtered;
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
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedBatchId = null;
      _selectedProductId = null;
    });
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
                  await ExportUtils.exportProductionToPDF(_filteredProductions);
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
                    _filteredProductions,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Export
          Row(
            children: [
              Expanded(
                child: Text('Production Reports', style: AppStyles.headingLg),
              ),
              if (_filteredProductions.isNotEmpty ||
                  _filteredBatches.isNotEmpty)
                AppButton(
                  text: 'Export',
                  icon: Icons.file_download,
                  onPressed: _showExportOptions,
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                ),
            ],
          ),
          const SizedBox(height: AppStyles.space4),

          // Filters
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filters', style: AppStyles.labelLg),
                const SizedBox(height: AppStyles.space4),

                // Date Range & Product Row
                ResponsiveLayout(
                  mobile: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: _startDate != null && _endDate != null
                              ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                              : 'Select Date Range',
                          icon: Icons.date_range,
                          onPressed: _selectDateRange,
                          variant: ButtonVariant.outline,
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space3),
                      if (_products.isNotEmpty)
                        DropdownButtonFormField<int>(
                          value: _selectedProductId,
                          decoration: InputDecoration(
                            labelText: 'Filter by Product',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusMd,
                              ),
                            ),
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
                            setState(() => _selectedProductId = value);
                          },
                        ),
                    ],
                  ),
                  tablet: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: _startDate != null && _endDate != null
                              ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                              : 'Select Date Range',
                          icon: Icons.date_range,
                          onPressed: _selectDateRange,
                          variant: ButtonVariant.outline,
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: AppStyles.space2),
                      if (_products.isNotEmpty)
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedProductId,
                            decoration: InputDecoration(
                              labelText: 'Product',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All'),
                              ),
                              ..._products.map(
                                (product) => DropdownMenuItem(
                                  value: product.productId,
                                  child: Text(product.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedProductId = value);
                            },
                          ),
                        ),
                      if (_startDate != null || _selectedProductId != null) ...[
                        const SizedBox(width: AppStyles.space2),
                        AppIconButton(
                          icon: Icons.clear,
                          onPressed: _clearFilters,
                          tooltip: 'Clear filters',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.space6),

          // Content
          if (_isLoading)
            const SizedBox(
              height: 300,
              child: AppLoadingState(message: 'Loading production reports...'),
            )
          else if (_error != null)
            SizedBox(
              height: 300,
              child: AppErrorState(
                title: 'Failed to load data',
                subtitle: _error,
                onRetry: _loadReports,
              ),
            )
          else
            _buildReportContent(),
        ],
      ),
    );
  }

  double get _totalInput =>
      _filteredProductions.fold<double>(0, (sum, p) => sum + p.inputQty);

  double get _totalOutput =>
      _filteredProductions.fold<double>(0, (sum, p) => sum + p.outputQty);

  Widget _buildReportContent() {
    final avgEfficiency = _filteredProductions.isEmpty
        ? 0.0
        : _filteredProductions.fold<double>(0, (sum, p) => sum + p.efficiency) /
              _filteredProductions.length;

    final totalBatches = _filteredBatches.length;
    final completedBatches = _filteredBatches
        .where((b) => b.status == 'completed')
        .length;
    final ongoingBatches = _filteredBatches
        .where((b) => b.status == 'ongoing')
        .length;
    final totalWorkerHours = _workerProgress.fold<int>(
      0,
      (sum, p) => sum + p.hoursWorked,
    );
    final activeWorkers = _workerProgress.map((p) => p.workerId).toSet().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 4,
          desktopColumns: 4,
          spacing: AppStyles.space4,
          children: [
            StatCard(
              title: 'Production Logs',
              value: '${_filteredProductions.length}',
              icon: Icons.factory,
              color: AppColors.primary,
              subtitle: 'Total entries',
            ),
            StatCard(
              title: 'Avg Efficiency',
              value: '${avgEfficiency.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: avgEfficiency >= 80
                  ? AppColors.success
                  : AppColors.warning,
              subtitle: avgEfficiency >= 80 ? 'Excellent' : 'Good',
            ),
            StatCard(
              title: 'Total Output',
              value: '${_totalOutput.toStringAsFixed(0)} kg',
              icon: Icons.production_quantity_limits,
              color: AppColors.success,
              subtitle: 'Material produced',
            ),
            StatCard(
              title: 'Active Batches',
              value: '$ongoingBatches',
              icon: Icons.inventory,
              color: AppColors.info,
              subtitle: 'of $totalBatches total',
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space6),

        // Batch Performance
        Text('Batch Performance', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          spacing: AppStyles.space4,
          children: [_buildBatchStatusChart(), _buildEfficiencyTrendChart()],
        ),
        const SizedBox(height: AppStyles.space6),

        // Machine Utilization
        Text('Machine & Workforce Utilization', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.engineering,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppStyles.space2),
                    Text('Workforce Metrics', style: AppStyles.labelLg),
                  ],
                ),
                const SizedBox(height: AppStyles.space4),
                _buildUtilizationBar(
                  'Active Workers',
                  activeWorkers,
                  _workerProgress.length,
                ),
                const SizedBox(height: AppStyles.space3),
                _buildUtilizationBar(
                  'Total Hours',
                  totalWorkerHours,
                  totalWorkerHours + 40,
                ),
                const SizedBox(height: AppStyles.space3),
                _buildUtilizationBar(
                  'Completed Batches',
                  completedBatches,
                  totalBatches > 0 ? totalBatches : 1,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppStyles.space6),

        // Production Details
        if (_filteredProductions.isNotEmpty) ...[
          Text(
            'Production Logs (${_filteredProductions.length})',
            style: AppStyles.headingSm,
          ),
          const SizedBox(height: AppStyles.space4),
          ..._filteredProductions.take(10).map((production) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppStyles.space3),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            production.productName ?? 'Unknown',
                            style: AppStyles.labelLg,
                          ),
                        ),
                        AppBadge(
                          text: '${production.efficiency.toStringAsFixed(1)}%',
                          variant: production.efficiency >= 80
                              ? BadgeVariant.success
                              : BadgeVariant.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.space2),
                    Text(
                      DateFormat(
                        'MMMM dd, yyyy',
                      ).format(DateTime.parse(production.date)),
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppStyles.space3),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProductionMetric(
                            Icons.arrow_downward,
                            'Input',
                            '${production.inputQty} kg',
                            AppColors.info,
                          ),
                        ),
                        Expanded(
                          child: _buildProductionMetric(
                            Icons.arrow_upward,
                            'Output',
                            '${production.outputQty} kg',
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _buildProductionMetric(
                            Icons.person,
                            'By',
                            production.supervisorName ?? 'Unknown',
                            AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],

        // Batch Summary
        if (_filteredBatches.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          Text(
            'Batch Summary (${_filteredBatches.length})',
            style: AppStyles.headingSm,
          ),
          const SizedBox(height: AppStyles.space4),
          ..._filteredBatches.take(5).map((batch) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppStyles.space3),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(batch.batchNumber, style: AppStyles.labelMd),
                          Text(
                            batch.productName,
                            style: AppStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppBadge(
                          text: batch.statusDisplay,
                          variant: _getBatchStatusBadge(batch.status),
                        ),
                        const SizedBox(height: AppStyles.space1),
                        Text(
                          batch.stageDisplay,
                          style: AppStyles.bodyXs.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildBatchStatusChart() {
    final completed = _filteredBatches
        .where((b) => b.status == 'completed')
        .length;
    final ongoing = _filteredBatches.where((b) => b.status == 'ongoing').length;
    final planned = _filteredBatches.where((b) => b.status == 'planned').length;
    final onHold = _filteredBatches.where((b) => b.status == 'on_hold').length;

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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: const Icon(
                    Icons.pie_chart,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                Text('Batch Status Distribution', style: AppStyles.labelLg),
              ],
            ),
            const SizedBox(height: AppStyles.space4),
            SizedBox(
              height: 200,
              child: _filteredBatches.isEmpty
                  ? Center(
                      child: Text(
                        'No batch data',
                        style: AppStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: [
                          if (completed > 0)
                            PieChartSectionData(
                              value: completed.toDouble(),
                              title: '$completed',
                              color: AppColors.success,
                              radius: 70,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (ongoing > 0)
                            PieChartSectionData(
                              value: ongoing.toDouble(),
                              title: '$ongoing',
                              color: AppColors.warning,
                              radius: 70,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (planned > 0)
                            PieChartSectionData(
                              value: planned.toDouble(),
                              title: '$planned',
                              color: AppColors.info,
                              radius: 70,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (onHold > 0)
                            PieChartSectionData(
                              value: onHold.toDouble(),
                              title: '$onHold',
                              color: AppColors.error,
                              radius: 70,
                              titleStyle: const TextStyle(
                                fontSize: 14,
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
            Wrap(
              spacing: AppStyles.space3,
              runSpacing: AppStyles.space2,
              children: [
                _buildLegendItem('Completed', AppColors.success),
                _buildLegendItem('Ongoing', AppColors.warning),
                _buildLegendItem('Planned', AppColors.info),
                _buildLegendItem('On Hold', AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyTrendChart() {
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: const Icon(
                    Icons.show_chart,
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
              child: _filteredProductions.isEmpty
                  ? Center(
                      child: Text(
                        'No production data',
                        style: AppStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(_filteredProductions.fold<double>(0, (sum, p) => sum + p.efficiency) / _filteredProductions.length).toStringAsFixed(1)}%',
                          style: AppStyles.headingLg.copyWith(
                            fontSize: 48,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space2),
                        Text(
                          'Average Efficiency',
                          style: AppStyles.labelMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Input', style: AppStyles.bodyXs),
                                Text(
                                  '${_totalInput.toStringAsFixed(0)} kg',
                                  style: AppStyles.labelMd,
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.textSecondary,
                            ),
                            Column(
                              children: [
                                Text('Output', style: AppStyles.bodyXs),
                                Text(
                                  '${_totalOutput.toStringAsFixed(0)} kg',
                                  style: AppStyles.labelMd,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizationBar(String label, int current, int total) {
    final percentage = total > 0 ? (current / total * 100) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppStyles.labelMd),
            Text(
              '$current / $total (${percentage.toStringAsFixed(0)}%)',
              style: AppStyles.bodySm.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space2),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: AppColors.gray200,
          color: AppColors.primary,
          minHeight: 10,
          borderRadius: BorderRadius.circular(AppStyles.radiusSm),
        ),
      ],
    );
  }

  Widget _buildProductionMetric(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
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

  BadgeVariant _getBatchStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return BadgeVariant.success;
      case 'ongoing':
        return BadgeVariant.warning;
      case 'planned':
        return BadgeVariant.info;
      case 'on_hold':
        return BadgeVariant.danger;
      default:
        return BadgeVariant.gray;
    }
  }
}
