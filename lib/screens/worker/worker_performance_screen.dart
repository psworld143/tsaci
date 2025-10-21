import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/worker_task_model.dart';
import '../../services/worker_task_service.dart';
import '../../services/auth_service.dart';

class WorkerPerformanceScreen extends StatefulWidget {
  const WorkerPerformanceScreen({Key? key}) : super(key: key);

  @override
  State<WorkerPerformanceScreen> createState() =>
      _WorkerPerformanceScreenState();
}

class _WorkerPerformanceScreenState extends State<WorkerPerformanceScreen> {
  List<WorkerTask> _allTasks = [];
  bool _isLoading = true;
  String _period = 'week';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return;

      final tasks = await WorkerTaskService.getTasksByWorkerId(user.userId);

      if (mounted) {
        setState(() {
          _allTasks = tasks
            ..sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<WorkerTask> get _filteredTasks {
    final now = DateTime.now();
    DateTime startDate;

    switch (_period) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        return _allTasks;
    }

    return _allTasks.where((task) {
      return task.assignedDate.isAfter(
        startDate.subtract(const Duration(days: 1)),
      );
    }).toList();
  }

  Map<String, dynamic> get _periodStats {
    final tasks = _filteredTasks;
    final completed = tasks.where((t) => t.isCompleted).toList();
    final totalOutput = completed.fold<double>(
      0,
      (sum, t) => sum + (t.completedQuantity ?? 0),
    );

    final avgEfficiency = completed.isNotEmpty
        ? completed.fold<double>(
                0,
                (sum, t) => sum + (t.completionPercentage),
              ) /
              completed.length
        : 0.0;

    // Calculate hours worked (rough estimate)
    int hoursWorked = 0;
    for (var task in completed) {
      if (task.startedAt != null && task.completedAt != null) {
        hoursWorked += task.completedAt!.difference(task.startedAt!).inHours;
      }
    }

    return {
      'total': tasks.length,
      'completed': completed.length,
      'output': totalOutput,
      'efficiency': avgEfficiency,
      'hours': hoursWorked,
    };
  }

  @override
  Widget build(BuildContext context) {
    final periodStats = _periodStats;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppStyles.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPeriodChip('today', 'Today'),
                        const SizedBox(width: AppStyles.space2),
                        _buildPeriodChip('week', 'This Week'),
                        const SizedBox(width: AppStyles.space2),
                        _buildPeriodChip('month', 'This Month'),
                        const SizedBox(width: AppStyles.space2),
                        _buildPeriodChip('all', 'All Time'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.space4),

                  // Performance Summary
                  AppCard(
                    color: AppColors.primary.withOpacity(0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Performance Summary', style: AppStyles.headingSm),
                        const SizedBox(height: AppStyles.space4),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetric(
                                'Tasks',
                                '${periodStats['completed']}/${periodStats['total']}',
                                Icons.task_alt,
                                AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: _buildMetric(
                                'Output',
                                '${periodStats['output'].toStringAsFixed(0)} kg',
                                Icons.inventory,
                                AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppStyles.space3),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetric(
                                'Efficiency',
                                '${periodStats['efficiency'].toStringAsFixed(1)}%',
                                Icons.trending_up,
                                AppColors.info,
                              ),
                            ),
                            Expanded(
                              child: _buildMetric(
                                'Hours',
                                '${periodStats['hours']}h',
                                Icons.access_time,
                                AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.space6),

                  // Work History
                  Text('Work History', style: AppStyles.headingSm),
                  const SizedBox(height: AppStyles.space3),

                  if (_filteredTasks.isEmpty)
                    const AppCard(
                      child: AppEmptyState(
                        icon: Icons.history,
                        title: 'No History',
                        subtitle: 'No tasks found for this period',
                      ),
                    )
                  else
                    ..._filteredTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppStyles.space2,
                        ),
                        child: _buildHistoryCard(task),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _period == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _period = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppStyles.bodyXs),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.headingMd.copyWith(color: color)),
      ],
    );
  }

  Widget _buildHistoryCard(WorkerTask task) {
    final color = task.isCompleted
        ? AppColors.success
        : task.isInProgress
        ? AppColors.info
        : AppColors.gray400;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
            ),
          ),
          const SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.productName, style: AppStyles.labelMd),
                Text(
                  DateFormat('MMM dd, yyyy').format(task.assignedDate),
                  style: AppStyles.bodyXs.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (task.completedQuantity != null)
                  Text(
                    'Output: ${task.completedQuantity} kg',
                    style: AppStyles.bodyXs.copyWith(color: AppColors.success),
                  ),
              ],
            ),
          ),
          AppBadge(
            text: task.statusDisplay,
            variant: task.isCompleted
                ? BadgeVariant.success
                : task.isInProgress
                ? BadgeVariant.info
                : BadgeVariant.gray,
          ),
        ],
      ),
    );
  }
}
