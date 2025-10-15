import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../models/worker_progress_model.dart';
import '../../models/user_model.dart';
import '../../services/worker_supervision_service.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class WorkerSupervisionScreen extends StatefulWidget {
  const WorkerSupervisionScreen({Key? key}) : super(key: key);

  @override
  State<WorkerSupervisionScreen> createState() =>
      _WorkerSupervisionScreenState();
}

class _WorkerSupervisionScreenState extends State<WorkerSupervisionScreen> {
  final UserService _userService = UserService();
  List<UserModel> _workers = [];
  List<WorkerProgress> _allProgress = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      print('[WorkerSupervision] Loading workers...');
      final allUsers = await _userService.getAllUsers();
      final workers = allUsers
          .where(
            (u) =>
                u.role.toLowerCase() == 'worker' ||
                u.role.toLowerCase() == 'supervisor',
          )
          .toList();
      print('[WorkerSupervision] Workers loaded: ${workers.length}');

      print('[WorkerSupervision] Loading progress reports...');
      final progress = await WorkerSupervisionService.getAllProgress();
      print('[WorkerSupervision] Progress reports loaded: ${progress.length}');

      setState(() {
        _workers = workers;
        _allProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      print('[WorkerSupervision] Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<WorkerProgress> _getProgressForDate() {
    return _allProgress.where((p) {
      return p.date.year == _selectedDate.year &&
          p.date.month == _selectedDate.month &&
          p.date.day == _selectedDate.day;
    }).toList();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _showAddFeedbackDialog(WorkerProgress progress) async {
    final feedbackController = TextEditingController();
    String selectedRating = 'good';

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusXl),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppStyles.space6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppStyles.radiusXl),
                        topRight: Radius.circular(AppStyles.radiusXl),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppStyles.space3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.rate_review,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Feedback',
                                style: AppStyles.headingMd.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'For ${progress.workerName}',
                                style: AppStyles.bodySm.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppStyles.space6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress Summary
                          Container(
                            padding: const EdgeInsets.all(AppStyles.space4),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusMd,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  progress.taskDescription,
                                  style: AppStyles.labelMd,
                                ),
                                const SizedBox(height: AppStyles.space2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${progress.hoursWorked} hours',
                                      style: AppStyles.bodySm,
                                    ),
                                    const SizedBox(width: AppStyles.space3),
                                    Icon(
                                      Icons.production_quantity_limits,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${progress.outputQuantity} ${progress.unit ?? ''}',
                                      style: AppStyles.bodySm,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppStyles.space6),

                          // Rating Selection
                          Text(
                            'Performance Rating *',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space3),

                          ...[
                            {
                              'value': 'excellent',
                              'label': 'Excellent',
                              'icon': Icons.star,
                              'color': AppColors.success,
                            },
                            {
                              'value': 'good',
                              'label': 'Good',
                              'icon': Icons.thumb_up,
                              'color': AppColors.info,
                            },
                            {
                              'value': 'needs_improvement',
                              'label': 'Needs Improvement',
                              'icon': Icons.trending_up,
                              'color': AppColors.warning,
                            },
                          ].map((rating) {
                            final isSelected =
                                selectedRating == rating['value'];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppStyles.space2,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    selectedRating = rating['value'] as String;
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppStyles.space4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (rating['color'] as Color).withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.gray50,
                                    borderRadius: BorderRadius.circular(
                                      AppStyles.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? (rating['color'] as Color)
                                          : AppColors.gray300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        rating['icon'] as IconData,
                                        color: rating['color'] as Color,
                                      ),
                                      const SizedBox(width: AppStyles.space3),
                                      Expanded(
                                        child: Text(
                                          rating['label'] as String,
                                          style: AppStyles.labelMd,
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: rating['color'] as Color,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: AppStyles.space6),

                          // Feedback Text
                          AppTextField(
                            controller: feedbackController,
                            label: 'Feedback / Remarks *',
                            prefixIcon: Icons.comment,
                            hint: 'Add your feedback and suggestions',
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space6),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppStyles.radiusXl),
                        bottomRight: Radius.circular(AppStyles.radiusXl),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            variant: ButtonVariant.outline,
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'Submit Feedback',
                            icon: Icons.send,
                            onPressed: () async {
                              if (feedbackController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter feedback'),
                                  ),
                                );
                                return;
                              }

                              try {
                                final currentUser =
                                    await AuthService.getCurrentUser();
                                if (currentUser == null) {
                                  throw Exception('User not authenticated');
                                }

                                await WorkerSupervisionService.addFeedback(
                                  progress: progress,
                                  managerId: currentUser.userId,
                                  managerName: currentUser.name,
                                  feedbackText: feedbackController.text,
                                  rating: selectedRating,
                                );

                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Feedback added successfully',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  _loadData();
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            fullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayProgress = _getProgressForDate();

    return Scaffold(
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: AppStyles.space2),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                    style: AppStyles.labelLg,
                  ),
                ),
                AppIconButton(
                  icon: Icons.calendar_month,
                  onPressed: _selectDate,
                  tooltip: 'Change date',
                ),
              ],
            ),
          ),

          // Summary Cards
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            child: ResponsiveGrid(
              mobileColumns: 2,
              tabletColumns: 4,
              desktopColumns: 4,
              spacing: AppStyles.space3,
              children: [
                _buildSummaryCard(
                  'Total Workers',
                  '${_workers.length}',
                  Icons.people,
                  AppColors.primary,
                ),
                _buildSummaryCard(
                  'Active Today',
                  '${todayProgress.length}',
                  Icons.work,
                  AppColors.info,
                ),
                _buildSummaryCard(
                  'Total Hours',
                  '${todayProgress.fold<int>(0, (sum, p) => sum + p.hoursWorked)}',
                  Icons.access_time,
                  AppColors.warning,
                ),
                _buildSummaryCard(
                  'With Feedback',
                  '${todayProgress.where((p) => p.feedbacks.isNotEmpty).length}',
                  Icons.rate_review,
                  AppColors.success,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _workers.isEmpty
                ? const Center(
                    child: AppEmptyState(
                      icon: Icons.people,
                      title: 'No Workers Found',
                      subtitle: 'No workers or supervisors available',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      itemCount: _workers.length,
                      itemBuilder: (context, index) {
                        final worker = _workers[index];
                        final workerProgress = todayProgress
                            .where((p) => p.workerId == worker.userId)
                            .toList();
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppStyles.space3,
                          ),
                          child: _buildWorkerCard(worker, workerProgress),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppStyles.space2),
          Text(value, style: AppStyles.headingSm.copyWith(color: color)),
          Text(label, style: AppStyles.bodyXs, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(
    UserModel worker,
    List<WorkerProgress> progressReports,
  ) {
    final hasProgress = progressReports.isNotEmpty;
    final totalHours = progressReports.fold<int>(
      0,
      (sum, p) => sum + p.hoursWorked,
    );
    final totalOutput = progressReports.fold<double>(
      0,
      (sum, p) => sum + p.outputQuantity,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Icon(
                  Icons.engineering,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name, style: AppStyles.labelLg),
                    Text(
                      worker.email,
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: hasProgress ? 'Active' : 'No Report',
                variant: hasProgress ? BadgeVariant.success : BadgeVariant.gray,
              ),
            ],
          ),

          if (hasProgress) ...[
            const SizedBox(height: AppStyles.space4),
            const Divider(),
            const SizedBox(height: AppStyles.space3),

            // Today's Summary
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    Icons.access_time,
                    'Hours',
                    '$totalHours hrs',
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    Icons.production_quantity_limits,
                    'Output',
                    '${totalOutput.toStringAsFixed(1)} kg',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    Icons.assignment,
                    'Tasks',
                    '${progressReports.length}',
                    AppColors.info,
                  ),
                ),
              ],
            ),

            // Progress Reports
            const SizedBox(height: AppStyles.space4),
            ...progressReports.map((progress) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppStyles.space3),
                child: Container(
                  padding: const EdgeInsets.all(AppStyles.space3),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              progress.taskDescription,
                              style: AppStyles.labelMd,
                            ),
                          ),
                          AppBadge(
                            text: progress.status.toUpperCase(),
                            variant: _getStatusBadgeVariant(progress.status),
                          ),
                        ],
                      ),
                      if (progress.batchNumber != null) ...[
                        const SizedBox(height: AppStyles.space1),
                        Text(
                          'Batch: ${progress.batchNumber}',
                          style: AppStyles.bodyXs.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (progress.notes != null) ...[
                        const SizedBox(height: AppStyles.space2),
                        Text(progress.notes!, style: AppStyles.bodyXs),
                      ],

                      // Feedbacks
                      if (progress.feedbacks.isNotEmpty) ...[
                        const SizedBox(height: AppStyles.space3),
                        const Divider(),
                        const SizedBox(height: AppStyles.space2),
                        ...progress.feedbacks.map((feedback) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppStyles.space2,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppStyles.space2),
                              decoration: BoxDecoration(
                                color: _getRatingColor(
                                  feedback.rating,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusSm,
                                ),
                                border: Border.all(
                                  color: _getRatingColor(
                                    feedback.rating,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getRatingIcon(feedback.rating),
                                        size: 14,
                                        color: _getRatingColor(feedback.rating),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        feedback.managerName,
                                        style: AppStyles.bodyXs.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat(
                                          'hh:mm a',
                                        ).format(feedback.createdAt),
                                        style: AppStyles.bodyXs.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    feedback.feedbackText,
                                    style: AppStyles.bodyXs,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],

                      // Add Feedback Button
                      const SizedBox(height: AppStyles.space2),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _showAddFeedbackDialog(progress),
                          icon: const Icon(Icons.add_comment, size: 16),
                          label: const Text('Add Feedback'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ] else ...[
            const SizedBox(height: AppStyles.space3),
            Container(
              padding: const EdgeInsets.all(AppStyles.space4),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary),
                  const SizedBox(width: AppStyles.space2),
                  Expanded(
                    child: Text(
                      'No progress report for ${DateFormat('MMM dd').format(_selectedDate)}',
                      style: AppStyles.bodySm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.labelMd.copyWith(color: color)),
        Text(
          label,
          style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return AppColors.info;
      case 'needs_improvement':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRatingIcon(String rating) {
    switch (rating.toLowerCase()) {
      case 'excellent':
        return Icons.star;
      case 'good':
        return Icons.thumb_up;
      case 'needs_improvement':
        return Icons.trending_up;
      default:
        return Icons.help;
    }
  }

  BadgeVariant _getStatusBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return BadgeVariant.success;
      case 'in_progress':
        return BadgeVariant.info;
      case 'delayed':
        return BadgeVariant.danger;
      default:
        return BadgeVariant.gray;
    }
  }
}
