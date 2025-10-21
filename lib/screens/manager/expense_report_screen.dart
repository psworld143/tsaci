import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

        // Analytics Section
        if (!_isLoading && _error == null && _expenses.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildAnalyticsSection(),
        ],

        // Charts Section
        if (!_isLoading && _error == null && _expenses.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildChartsSection(),
        ],

        // Predictive Analysis
        if (!_isLoading && _error == null && _expenses.isNotEmpty) ...[
          const SizedBox(height: AppStyles.space6),
          _buildPredictiveAnalysis(),
        ],
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

  // Analytics Section
  Widget _buildAnalyticsSection() {
    final totalExpenses = _expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final expenseCount = _expenses.length;
    final avgExpense = expenseCount > 0 ? totalExpenses / expenseCount : 0.0;

    // Largest expense
    final largestExpense = _expenses.isNotEmpty
        ? _expenses.reduce((a, b) => a.amount > b.amount ? a : b).amount
        : 0.0;

    // Most common category
    final categoryCounts = <String, int>{};
    for (final expense in _expenses) {
      categoryCounts[expense.category] =
          (categoryCounts[expense.category] ?? 0) + 1;
    }
    final mostCommonCategory = categoryCounts.entries.isNotEmpty
        ? categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    // Department with highest spending
    final departmentSpending = <String, double>{};
    for (final expense in _expenses) {
      if (expense.department != null) {
        departmentSpending[expense.department!] =
            (departmentSpending[expense.department!] ?? 0) + expense.amount;
      }
    }
    final topDepartment = departmentSpending.entries.isNotEmpty
        ? departmentSpending.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
        : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expense Analytics', style: AppStyles.headingMd),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: AppStyles.space4,
          children: [
            _buildAnalyticsCard(
              'Total Expenses',
              '₱${totalExpenses.toStringAsFixed(2)}',
              Icons.receipt_long,
              AppColors.error,
            ),
            _buildAnalyticsCard(
              'Expense Count',
              expenseCount.toString(),
              Icons.list_alt,
              AppColors.info,
            ),
            _buildAnalyticsCard(
              'Average Expense',
              '₱${avgExpense.toStringAsFixed(2)}',
              Icons.analytics,
              AppColors.primary,
            ),
            _buildAnalyticsCard(
              'Largest Expense',
              '₱${largestExpense.toStringAsFixed(2)}',
              Icons.trending_up,
              AppColors.warning,
            ),
            _buildAnalyticsCard(
              'Most Common Category',
              mostCommonCategory.length > 15
                  ? '${mostCommonCategory.substring(0, 15)}...'
                  : mostCommonCategory,
              Icons.category,
              AppColors.success,
            ),
            _buildAnalyticsCard(
              'Top Department',
              topDepartment.length > 15
                  ? '${topDepartment.substring(0, 15)}...'
                  : topDepartment,
              Icons.business,
              AppColors.info,
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
        Text('Expense Analytics Charts', style: AppStyles.headingMd),
        const SizedBox(height: AppStyles.space4),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          spacing: AppStyles.space4,
          children: [
            _buildExpenseTrendChart(),
            _buildExpenseByCategoryChart(),
            _buildCategoryDistributionChart(),
            _buildMonthlyExpenseChart(),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseTrendChart() {
    if (_expenses.isEmpty) {
      return _buildEmptyChart('Expense Trend', 'No expense data available');
    }

    // Group expenses by date
    final Map<String, List<ExpenseModel>> groupedByDate = {};
    for (final expense in _expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      groupedByDate[dateKey] = (groupedByDate[dateKey] ?? [])..add(expense);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final expenses = groupedByDate[date]!;
      final dailyExpense = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
      spots.add(FlSpot(i.toDouble(), dailyExpense));
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
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Text('Expense Trend', style: AppStyles.labelLg),
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
                    color: AppColors.error,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.error.withOpacity(0.1),
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

  Widget _buildExpenseByCategoryChart() {
    if (_expenses.isEmpty) {
      return _buildEmptyChart(
        'Expense by Category',
        'No expense data available',
      );
    }

    // Group expenses by category
    final Map<String, double> categoryExpenses = {};
    for (final expense in _expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryExpenses.entries.toList()
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
              Text('Expense by Category', style: AppStyles.labelLg),
            ],
          ),
          const SizedBox(height: AppStyles.space4),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedCategories.isNotEmpty
                    ? sortedCategories.first.value * 1.2
                    : 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < sortedCategories.length) {
                          final category = sortedCategories[value.toInt()];
                          return Text(
                            category.key.length > 8
                                ? '${category.key.substring(0, 8)}...'
                                : category.key,
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
                barGroups: sortedCategories.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
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

  Widget _buildCategoryDistributionChart() {
    if (_expenses.isEmpty) {
      return _buildEmptyChart(
        'Category Distribution',
        'No expense data available',
      );
    }

    final categoryCounts = <String, int>{};
    for (final expense in _expenses) {
      categoryCounts[expense.category] =
          (categoryCounts[expense.category] ?? 0) + 1;
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

  Widget _buildMonthlyExpenseChart() {
    if (_expenses.isEmpty) {
      return _buildEmptyChart('Monthly Expense', 'No expense data available');
    }

    // Group expenses by month
    final Map<String, double> monthlyExpenses = {};
    for (final expense in _expenses) {
      final monthKey = DateFormat('yyyy-MM').format(expense.date);
      monthlyExpenses[monthKey] =
          (monthlyExpenses[monthKey] ?? 0) + expense.amount;
    }

    final sortedMonths = monthlyExpenses.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final expense = monthlyExpenses[month]!;
      spots.add(FlSpot(i.toDouble(), expense));
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
              Text('Monthly Expense Trend', style: AppStyles.labelLg),
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
              'Next Month Expense Forecast',
              _predictNextMonthExpense(),
              Icons.trending_up,
              AppColors.error,
            ),
            _buildPredictionCard(
              'Budget Alert',
              _predictBudgetAlert(),
              Icons.warning,
              AppColors.warning,
            ),
            _buildPredictionCard(
              'Cost Optimization',
              _predictCostOptimization(),
              Icons.savings,
              AppColors.success,
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

  String _predictNextMonthExpense() {
    if (_expenses.length < 2) return 'Insufficient data for prediction';

    final recentExpenses = _expenses.take(5).map((e) => e.amount).toList();
    final avgExpense =
        recentExpenses.fold<double>(0, (sum, expense) => sum + expense) /
        recentExpenses.length;
    final predictedExpense = avgExpense * 1.05; // 5% increase assumption

    return 'Predicted expense: ₱${predictedExpense.toStringAsFixed(2)}\nBased on recent trends';
  }

  String _predictBudgetAlert() {
    if (_expenses.length < 3) return 'Need more data for analysis';

    final recentExpenses = _expenses.take(5).map((e) => e.amount).toList();
    final avgExpense =
        recentExpenses.fold<double>(0, (sum, expense) => sum + expense) /
        recentExpenses.length;

    if (avgExpense >= 2000) {
      return 'High spending trend\nConsider budget review';
    } else if (avgExpense >= 1000) {
      return 'Moderate spending\nMonitor closely';
    } else {
      return 'Low spending trend\nGood budget control';
    }
  }

  String _predictCostOptimization() {
    if (_expenses.isEmpty) return 'No data available';

    final categoryExpenses = <String, double>{};
    for (final expense in _expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }

    final topCategory = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topCategory.isNotEmpty) {
      return 'Focus on: ${topCategory.first.key}\nHighest spending category';
    }

    return 'Analyze spending patterns\nIdentify optimization opportunities';
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
