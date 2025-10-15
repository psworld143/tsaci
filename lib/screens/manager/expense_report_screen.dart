import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../utils/export_utils.dart';
import '../../models/expense_model.dart';
import '../../services/expense_service.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final expenses = await _expenseService.getAllExpenses();

      // Apply filters
      List<ExpenseModel> filteredExpenses = expenses;

      if (_startDate != null && _endDate != null) {
        filteredExpenses = filteredExpenses.where((expense) {
          return expense.date.isAfter(
                _startDate!.subtract(const Duration(days: 1)),
              ) &&
              expense.date.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      }

      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        filteredExpenses = filteredExpenses.where((expense) {
          return expense.category.toLowerCase() ==
              _selectedCategory!.toLowerCase();
        }).toList();
      }

      setState(() {
        _expenses = filteredExpenses;
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
      _loadExpenses();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategory = null;
    });
    _loadExpenses();
  }

  Map<String, double> _getCategoryBreakdown() {
    final Map<String, double> breakdown = {};
    for (var expense in _expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0) + expense.amount;
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
              subtitle: const Text('Formatted report with breakdown'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ExportUtils.exportExpensesToPDF(_expenses);
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
                  final path = await ExportUtils.exportExpensesToCSV(_expenses);
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
                  if (_startDate != null || _selectedCategory != null)
                    AppIconButton(
                      icon: Icons.clear,
                      onPressed: _clearFilters,
                      tooltip: 'Clear filters',
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppStyles.space6),

        // Content
        if (_isLoading)
          const SizedBox(
            height: 300,
            child: AppLoadingState(message: 'Loading expense data...'),
          )
        else if (_error != null)
          SizedBox(
            height: 300,
            child: AppErrorState(
              title: 'Failed to load data',
              subtitle: _error,
              onRetry: _loadExpenses,
            ),
          )
        else if (_expenses.isEmpty)
          const SizedBox(
            height: 300,
            child: AppEmptyState(
              icon: Icons.receipt_long,
              title: 'No expense data',
              subtitle: 'No expenses found for the selected filters',
            ),
          )
        else
          _buildExpenseReport(),
      ],
    );

    // If inside AdminLayout, just return scrollable content
    if (hasScaffold) {
      return RefreshIndicator(
        onRefresh: _loadExpenses,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.space4),
          child: content,
        ),
      );
    }

    // Otherwise, use full scaffold (for Manager drawer navigation)
    return ScrollableAppScaffold(
      title: 'Expense Report',
      onRefresh: _loadExpenses,
      useResponsiveContainer: false,
      actions: _expenses.isNotEmpty
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

  Widget _buildExpenseReport() {
    final totalExpenses = _expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final categoryBreakdown = _getCategoryBreakdown();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 3,
          desktopColumns: 3,
          spacing: AppStyles.space4,
          children: [
            StatCard(
              title: 'Total Expenses',
              value: '₱${totalExpenses.toStringAsFixed(2)}',
              icon: Icons.receipt_long,
              color: AppColors.error,
            ),
            StatCard(
              title: 'Transactions',
              value: '${_expenses.length}',
              icon: Icons.list_alt,
              color: AppColors.info,
            ),
            StatCard(
              title: 'Categories',
              value: '${categoryBreakdown.length}',
              icon: Icons.category,
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space6),

        // Category Breakdown
        Text('Expense Breakdown by Category', style: AppStyles.headingSm),
        const SizedBox(height: AppStyles.space4),
        AppCard(
          child: Column(
            children: categoryBreakdown.entries.map((entry) {
              final percentage = (entry.value / totalExpenses * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppStyles.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: AppStyles.labelMd),
                        Text(
                          '₱${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                          style: AppStyles.labelMd.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.space2),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.gray200,
                      color: AppColors.error,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppStyles.space6),

        // Expense List
        Text(
          'Expense Details (${_expenses.length} items)',
          style: AppStyles.headingSm,
        ),
        const SizedBox(height: AppStyles.space4),
        ...List.generate(_expenses.length, (index) {
          final expense = _expenses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppStyles.space3),
            child: AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    child: const Icon(
                      Icons.receipt,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expense.category, style: AppStyles.labelMd),
                        const SizedBox(height: AppStyles.space1),
                        if (expense.description != null)
                          Text(
                            expense.description!,
                            style: AppStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: AppStyles.space1),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppStyles.space1),
                            Text(
                              DateFormat('MMM d, y').format(expense.date),
                              style: AppStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (expense.department != null) ...[
                              const SizedBox(width: AppStyles.space2),
                              const Text('•'),
                              const SizedBox(width: AppStyles.space2),
                              Text(
                                expense.department!,
                                style: AppStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₱${expense.amount.toStringAsFixed(2)}',
                    style: AppStyles.headingSm.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
