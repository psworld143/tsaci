import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../services/expense_service.dart';
import '../../models/expense_model.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseManagementScreen> createState() =>
      _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String? _error;

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
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingState();
    }

    if (_error != null) {
      return AppErrorState(
        title: 'Error Loading Expenses',
        subtitle: _error!,
        onRetry: _loadExpenses,
      );
    }

    final totalExpenses = _expenses.fold<double>(
      0,
      (sum, exp) => sum + exp.amount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          StatCard(
            title: 'Total Expenses',
            value: '₱${totalExpenses.toStringAsFixed(2)}',
            icon: Icons.receipt_long,
            color: AppColors.error,
            subtitle: '${_expenses.length} transactions',
          ),
          const SizedBox(height: AppStyles.space6),

          // Expenses List
          Text('Recent Expenses', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),

          if (_expenses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppStyles.space6),
                child: AppEmptyState(
                  icon: Icons.receipt_outlined,
                  title: 'No Expenses',
                  subtitle: 'Expense records will appear here',
                ),
              ),
            )
          else
            ...List.generate(_expenses.length, (index) {
              final expense = _expenses[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppStyles.space3),
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
                              maxLines: 1,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₱${expense.amount.toStringAsFixed(2)}',
                          style: AppStyles.headingSm.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
