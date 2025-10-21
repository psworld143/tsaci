import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/worker_task_model.dart';
import '../../services/worker_task_service.dart';
import '../../services/auth_service.dart';
import '../../services/offline/sync_service.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  List<WorkerTask> _tasks = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isOnline = true;

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

      // Initialize demo tasks if first time
      await WorkerTaskService.initializeDemoTasks(user.userId, user.name);

      final tasks = await WorkerTaskService.getTodaysTasks(user.userId);
      final stats = await WorkerTaskService.getWorkerStatistics(user.userId);
      final isOnline = await SyncService.isOnline();

      if (mounted) {
        setState(() {
          _tasks = tasks
            ..sort((a, b) {
              // Sort: in_progress, not_started, completed
              if (a.isInProgress && !b.isInProgress) return -1;
              if (!a.isInProgress && b.isInProgress) return 1;
              if (a.isCompleted && !b.isCompleted) return 1;
              if (!a.isCompleted && b.isCompleted) return -1;
              return 0;
            });
          _stats = stats;
          _isOnline = isOnline;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleStartTask(WorkerTask task) async {
    try {
      await WorkerTaskService.startTask(task.taskId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task started'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleCompleteTask(WorkerTask task) async {
    final quantityController = TextEditingController(
      text: task.targetQuantity.toString(),
    );
    final notesController = TextEditingController(text: task.notes ?? '');

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppStyles.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete Task', style: AppStyles.headingMd),
                        Text(
                          task.productName,
                          style: AppStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.space6),

              // Completed Quantity
              AppTextField(
                controller: quantityController,
                label: 'Completed Quantity (kg)',
                prefixIcon: Icons.scale,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppStyles.space4),

              // Notes
              AppTextField(
                controller: notesController,
                label: 'Notes (optional)',
                prefixIcon: Icons.note,
                hint: 'Add any observations or issues',
                maxLines: 3,
              ),
              const SizedBox(height: AppStyles.space6),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      variant: ButtonVariant.outline,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'Mark Complete',
                      icon: Icons.check,
                      onPressed: () async {
                        final quantity = double.tryParse(
                          quantityController.text,
                        );

                        if (quantity == null || quantity <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid quantity'),
                            ),
                          );
                          return;
                        }

                        try {
                          await WorkerTaskService.completeTask(
                            task.taskId!,
                            quantity,
                            notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task completed successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );

                          _loadData();
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    quantityController.dispose();
    notesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = _stats['today_tasks'] ?? 0;
    final todayCompleted = _stats['today_completed'] ?? 0;
    final totalOutput = _stats['total_output'] ?? 0.0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: AppStyles.space4,
                right: AppStyles.space4,
                top: AppStyles.space4,
                bottom: AppStyles.space20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Online Status
                  Row(
                    children: [
                      Icon(
                        _isOnline ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: _isOnline ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: AppStyles.space1),
                      Text(
                        _isOnline ? 'Online' : 'Offline Mode',
                        style: AppStyles.bodySm.copyWith(
                          color: _isOnline
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.space4),

                  // KPI Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "Today's Tasks",
                          value: '$todayTasks',
                          icon: Icons.task,
                          color: AppColors.primary,
                          subtitle: '$todayCompleted completed',
                        ),
                      ),
                      const SizedBox(width: AppStyles.space3),
                      Expanded(
                        child: StatCard(
                          title: 'Total Output',
                          value: '${totalOutput.toStringAsFixed(0)} kg',
                          icon: Icons.production_quantity_limits,
                          color: AppColors.success,
                          subtitle: 'All time',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.space6),

                  // Section Header
                  Text('Today\'s Assignments', style: AppStyles.headingSm),
                  const SizedBox(height: AppStyles.space3),

                  // Task List
                  if (_tasks.isEmpty)
                    const AppCard(
                      child: AppEmptyState(
                        icon: Icons.task_alt,
                        title: 'No Tasks for Today',
                        subtitle: 'Check back later for new assignments',
                      ),
                    )
                  else
                    ..._tasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppStyles.space3,
                        ),
                        child: _buildTaskCard(task),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTaskCard(WorkerTask task) {
    final color = task.isCompleted
        ? AppColors.success
        : task.isInProgress
        ? AppColors.info
        : AppColors.gray400;

    return AppCard(
      border: task.isInProgress ? Border.all(color: color, width: 2) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : task.isInProgress
                      ? Icons.play_circle
                      : Icons.radio_button_unchecked,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.productName, style: AppStyles.labelLg),
                    Text(
                      task.batchNumber,
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: task.statusDisplay.toUpperCase(),
                variant: task.isCompleted
                    ? BadgeVariant.success
                    : task.isInProgress
                    ? BadgeVariant.info
                    : BadgeVariant.gray,
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space3),

          // Target Quantity
          Row(
            children: [
              const Icon(Icons.scale, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppStyles.space1),
              Text(
                'Target: ${task.targetQuantity} kg',
                style: AppStyles.bodySm,
              ),
              if (task.completedQuantity != null) ...[
                const SizedBox(width: AppStyles.space2),
                Text('•', style: AppStyles.bodySm),
                const SizedBox(width: AppStyles.space2),
                Text(
                  'Completed: ${task.completedQuantity} kg',
                  style: AppStyles.bodySm.copyWith(color: AppColors.success),
                ),
              ],
            ],
          ),

          // Progress Bar for In Progress Tasks
          if (task.isInProgress && task.completedQuantity != null) ...[
            const SizedBox(height: AppStyles.space3),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
              child: LinearProgressIndicator(
                value: task.completionPercentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space1),
            Text(
              '${task.completionPercentage.toStringAsFixed(0)}% Complete',
              style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
            ),
          ],

          // Time Information
          if (task.startedAt != null) ...[
            const SizedBox(height: AppStyles.space2),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  task.isCompleted
                      ? 'Completed: ${DateFormat('hh:mm a').format(task.completedAt!)}'
                      : 'Started: ${DateFormat('hh:mm a').format(task.startedAt!)}',
                  style: AppStyles.bodyXs,
                ),
              ],
            ),
          ],

          // Notes
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            const SizedBox(height: AppStyles.space2),
            Container(
              padding: const EdgeInsets.all(AppStyles.space2),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppStyles.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppStyles.space2),
                  Expanded(child: Text(task.notes!, style: AppStyles.bodyXs)),
                ],
              ),
            ),
          ],

          // Actions
          if (!task.isCompleted) ...[
            const SizedBox(height: AppStyles.space3),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (task.isNotStarted)
                  AppButton(
                    text: 'Start Task',
                    icon: Icons.play_arrow,
                    onPressed: () => _handleStartTask(task),
                    size: ButtonSize.sm,
                  ),
                if (task.isInProgress)
                  AppButton(
                    text: 'Mark Complete',
                    icon: Icons.check,
                    onPressed: () => _handleCompleteTask(task),
                    size: ButtonSize.sm,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
