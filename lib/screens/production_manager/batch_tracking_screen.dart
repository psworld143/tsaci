import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../models/production_batch_model.dart';
import '../../services/batch_service.dart';

class BatchTrackingScreen extends StatefulWidget {
  const BatchTrackingScreen({Key? key}) : super(key: key);

  @override
  State<BatchTrackingScreen> createState() => _BatchTrackingScreenState();
}

class _BatchTrackingScreenState extends State<BatchTrackingScreen> {
  List<ProductionBatch> _batches = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  final List<String> _stages = ['mixing', 'packing', 'qa', 'dispatch'];
  final Map<String, String> _stageLabels = {
    'mixing': 'Mixing',
    'packing': 'Packing',
    'qa': 'QA Check',
    'dispatch': 'Dispatch',
  };

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);

    try {
      print('[BatchTracking] Loading batches...');
      final batches = await BatchService.getAllBatches();
      print('[BatchTracking] Batches loaded: ${batches.length}');

      setState(() {
        _batches = batches
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
        _isLoading = false;
      });
    } catch (e) {
      print('[BatchTracking] Error loading batches: $e');
      setState(() => _isLoading = false);
    }
  }

  List<ProductionBatch> get _filteredBatches {
    if (_filterStatus == 'all') return _batches;
    return _batches
        .where((b) => b.status.toLowerCase() == _filterStatus)
        .toList();
  }

  Future<void> _updateBatchStage(ProductionBatch batch, String newStage) async {
    try {
      final currentIndex = _stages.indexOf(batch.currentStage.toLowerCase());
      final newIndex = _stages.indexOf(newStage.toLowerCase());

      // Prevent moving backward
      if (newIndex < currentIndex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot move batch to a previous stage'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Update stage via API
      final result = await BatchService.updateStage(batch.batchId!, newStage);

      // If moved to dispatch, also update status to completed
      if (newStage == 'dispatch' && result['success'] == true) {
        await BatchService.updateStatus(batch.batchId!, 'completed');
      }

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: AppStyles.space2),
                  Text('Batch moved to ${_stageLabels[newStage]}'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadBatches();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update stage'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating stage: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateBatchStatus(
    ProductionBatch batch,
    String newStatus,
  ) async {
    try {
      // Update status via API
      final result = await BatchService.updateStatus(batch.batchId!, newStatus);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: AppStyles.space2),
                  Text('Batch status updated to ${newStatus.toUpperCase()}'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadBatches();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update status'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showStageProgressDialog(ProductionBatch batch) {
    showDialog(
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    child: const Icon(
                      Icons.track_changes,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Move to Next Stage', style: AppStyles.labelLg),
                        Text(
                          batch.batchNumber,
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

              // Stage Options
              ..._stages.map((stage) {
                final currentIndex = _stages.indexOf(
                  batch.currentStage.toLowerCase(),
                );
                final stageIndex = _stages.indexOf(stage);
                final isPast = stageIndex < currentIndex;
                final isCurrent = stageIndex == currentIndex;
                final isNext = stageIndex == currentIndex + 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppStyles.space2),
                  child: InkWell(
                    onTap: isNext
                        ? () {
                            Navigator.pop(context);
                            _updateBatchStage(batch, stage);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      decoration: BoxDecoration(
                        color: isPast
                            ? AppColors.success.withValues(alpha: 0.1)
                            : isCurrent
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : isNext
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.gray300,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPast
                                ? Icons.check_circle
                                : isCurrent
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isPast
                                ? AppColors.success
                                : isCurrent
                                ? AppColors.primary
                                : AppColors.gray400,
                          ),
                          const SizedBox(width: AppStyles.space3),
                          Expanded(
                            child: Text(
                              _stageLabels[stage]!,
                              style: AppStyles.labelMd.copyWith(
                                color: isPast || isCurrent
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            AppBadge(
                              text: 'Current',
                              variant: BadgeVariant.primary,
                            ),
                          if (isNext)
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.warning,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: AppStyles.space4),
              AppButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
                variant: ButtonVariant.outline,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(ProductionBatch batch) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
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
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    child: const Icon(Icons.update, color: AppColors.warning),
                  ),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Update Status', style: AppStyles.labelLg),
                        Text(
                          batch.batchNumber,
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

              // Status Options
              _buildStatusOption(
                batch,
                'ongoing',
                'Ongoing',
                Icons.hourglass_empty,
                AppColors.warning,
              ),
              const SizedBox(height: AppStyles.space2),
              _buildStatusOption(
                batch,
                'on_hold',
                'On Hold',
                Icons.pause_circle,
                AppColors.error,
              ),
              const SizedBox(height: AppStyles.space2),
              _buildStatusOption(
                batch,
                'completed',
                'Completed',
                Icons.check_circle,
                AppColors.success,
              ),

              const SizedBox(height: AppStyles.space4),
              AppButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
                variant: ButtonVariant.outline,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    ProductionBatch batch,
    String status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isCurrent = batch.status.toLowerCase() == status;

    return InkWell(
      onTap: isCurrent
          ? null
          : () {
              Navigator.pop(context);
              _updateBatchStatus(batch, status);
            },
      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppStyles.space4),
        decoration: BoxDecoration(
          color: isCurrent ? color.withValues(alpha: 0.1) : AppColors.gray50,
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          border: Border.all(
            color: isCurrent ? color : AppColors.gray300,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppStyles.space3),
            Expanded(
              child: Text(
                label,
                style: AppStyles.labelMd.copyWith(
                  color: isCurrent ? color : AppColors.textPrimary,
                ),
              ),
            ),
            if (isCurrent)
              AppBadge(text: 'Current', variant: BadgeVariant.info),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All Batches', _batches.length),
                  const SizedBox(width: AppStyles.space2),
                  _buildFilterChip(
                    'planned',
                    'Planned',
                    _batches.where((b) => b.status == 'planned').length,
                  ),
                  const SizedBox(width: AppStyles.space2),
                  _buildFilterChip(
                    'ongoing',
                    'Ongoing',
                    _batches.where((b) => b.status == 'ongoing').length,
                  ),
                  const SizedBox(width: AppStyles.space2),
                  _buildFilterChip(
                    'on_hold',
                    'On Hold',
                    _batches.where((b) => b.status == 'on_hold').length,
                  ),
                  const SizedBox(width: AppStyles.space2),
                  _buildFilterChip(
                    'completed',
                    'Completed',
                    _batches.where((b) => b.status == 'completed').length,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBatches.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.track_changes,
                      title: 'No Batches Found',
                      subtitle: _filterStatus == 'all'
                          ? 'Create a batch in Production Planning'
                          : 'No batches with status: $_filterStatus',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBatches,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      itemCount: _filteredBatches.length,
                      itemBuilder: (context, index) {
                        final batch = _filteredBatches[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppStyles.space4,
                          ),
                          child: _buildBatchCard(batch),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.gray300,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildBatchCard(ProductionBatch batch) {
    final currentStageIndex = _stages.indexOf(batch.currentStage.toLowerCase());
    final canProgressStage =
        currentStageIndex >= 0 && currentStageIndex < _stages.length - 1;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.batchNumber, style: AppStyles.labelLg),
                    const SizedBox(height: AppStyles.space1),
                    Text(
                      batch.productName,
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: batch.statusDisplay,
                variant: _getStatusBadgeVariant(batch.status),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space4),

          // Stage Progress Indicator
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timeline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppStyles.space2),
                    Text(
                      'Production Progress',
                      style: AppStyles.labelSm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.space3),
                Row(
                  children: List.generate(_stages.length * 2 - 1, (index) {
                    if (index.isOdd) {
                      // Connector
                      final stageIndex = index ~/ 2;
                      return Expanded(
                        child: Container(
                          height: 2,
                          color: stageIndex < currentStageIndex
                              ? AppColors.success
                              : AppColors.gray300,
                        ),
                      );
                    } else {
                      // Stage dot
                      final stageIndex = index ~/ 2;
                      final stage = _stages[stageIndex];
                      final isPast = stageIndex < currentStageIndex;
                      final isCurrent = stageIndex == currentStageIndex;

                      return Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isPast
                                  ? AppColors.success
                                  : isCurrent
                                  ? AppColors.primary
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isPast || isCurrent
                                    ? (isPast
                                          ? AppColors.success
                                          : AppColors.primary)
                                    : AppColors.gray300,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isPast
                                  ? Icons.check
                                  : isCurrent
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              color: isPast
                                  ? Colors.white
                                  : isCurrent
                                  ? Colors.white
                                  : AppColors.gray400,
                              size: isPast || isCurrent ? 18 : 12,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space1),
                          Text(
                            _stageLabels[stage]!,
                            style: AppStyles.bodyXs.copyWith(
                              color: isPast || isCurrent
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.space4),

          // Details Grid
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 4,
            desktopColumns: 4,
            spacing: AppStyles.space3,
            children: [
              _buildDetailItem(
                Icons.production_quantity_limits,
                'Target',
                '${batch.targetQuantity} ${batch.unit}',
              ),
              _buildDetailItem(
                Icons.calendar_today,
                'Scheduled',
                DateFormat('MMM dd').format(batch.scheduledDate),
              ),
              _buildDetailItem(
                Icons.people,
                'Team',
                '${batch.supervisorNames.length + batch.workerNames.length}',
              ),
              _buildDetailItem(Icons.timeline, 'Stage', batch.stageDisplay),
            ],
          ),

          // Team Info
          if (batch.supervisorNames.isNotEmpty ||
              batch.workerNames.isNotEmpty) ...[
            const SizedBox(height: AppStyles.space3),
            Wrap(
              spacing: AppStyles.space2,
              runSpacing: AppStyles.space2,
              children: [
                ...batch.supervisorNames.map(
                  (name) => Chip(
                    avatar: const Icon(Icons.business_center, size: 16),
                    label: Text(name, style: AppStyles.bodyXs),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                ...batch.workerNames.map(
                  (name) => Chip(
                    avatar: const Icon(Icons.engineering, size: 16),
                    label: Text(name, style: AppStyles.bodyXs),
                    backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ],

          // Notes
          if (batch.notes != null) ...[
            const SizedBox(height: AppStyles.space3),
            Container(
              padding: const EdgeInsets.all(AppStyles.space3),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppStyles.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.note,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppStyles.space2),
                  Expanded(child: Text(batch.notes!, style: AppStyles.bodyXs)),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppStyles.space3),
          const Divider(),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (canProgressStage && batch.status != 'completed')
                TextButton.icon(
                  onPressed: () => _showStageProgressDialog(batch),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Next Stage'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              const SizedBox(width: AppStyles.space2),
              if (batch.status != 'completed')
                TextButton.icon(
                  onPressed: () => _showStatusDialog(batch),
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('Update Status'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.labelMd),
      ],
    );
  }

  BadgeVariant _getStatusBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return BadgeVariant.info;
      case 'ongoing':
        return BadgeVariant.warning;
      case 'on_hold':
        return BadgeVariant.danger;
      case 'completed':
        return BadgeVariant.success;
      case 'cancelled':
        return BadgeVariant.gray;
      default:
        return BadgeVariant.gray;
    }
  }
}
