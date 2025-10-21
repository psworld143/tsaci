import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/quality_inspection_model.dart';
import '../../services/quality_inspection_service.dart';
import '../../utils/responsive.dart';

class QualityMetricsScreen extends StatefulWidget {
  const QualityMetricsScreen({Key? key}) : super(key: key);

  @override
  State<QualityMetricsScreen> createState() => _QualityMetricsScreenState();
}

class _QualityMetricsScreenState extends State<QualityMetricsScreen> {
  List<QualityInspection> _inspections = [];
  bool _isLoading = true;
  String _timePeriod = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final inspections = await QualityInspectionService.getAllInspections();

      if (mounted) {
        setState(() {
          _inspections = inspections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<QualityInspection> get _filteredInspections {
    if (_timePeriod == 'all') return _inspections;

    final now = DateTime.now();
    DateTime startDate;

    switch (_timePeriod) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        return _inspections;
    }

    return _inspections.where((insp) {
      return insp.inspectionDate.isAfter(startDate);
    }).toList();
  }

  Map<String, int> get _statusBreakdown {
    return {
      'approved': _filteredInspections.where((i) => i.isApproved).length,
      'rejected': _filteredInspections.where((i) => i.isRejected).length,
      'pending': _filteredInspections.where((i) => i.isPending).length,
    };
  }

  Map<String, int> get _defectsBySeverity {
    final defects = <String, int>{
      'critical': 0,
      'major': 0,
      'minor': 0,
      'cosmetic': 0,
    };

    for (var inspection in _filteredInspections) {
      for (var defect in inspection.defects) {
        defects[defect.severity] = (defects[defect.severity] ?? 0) + 1;
      }
    }

    return defects;
  }

  Map<String, dynamic> get _qualityMetrics {
    final total = _filteredInspections.length;
    final approved = _statusBreakdown['approved'] ?? 0;
    final rejected = _statusBreakdown['rejected'] ?? 0;
    final totalDefects = _filteredInspections.fold<int>(
      0,
      (sum, i) => sum + i.defectCount,
    );
    final criticalDefects = _filteredInspections.fold<int>(
      0,
      (sum, i) => sum + i.criticalDefects,
    );

    return {
      'total': total,
      'approved': approved,
      'rejected': rejected,
      'pass_rate': total > 0
          ? (approved / total * 100).toStringAsFixed(1)
          : '0.0',
      'total_defects': totalDefects,
      'critical_defects': criticalDefects,
      'defect_rate': total > 0
          ? (totalDefects / total).toStringAsFixed(2)
          : '0.0',
    };
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _qualityMetrics;

    return Column(
      children: [
        // Time Period Selector
        Container(
          padding: const EdgeInsets.all(AppStyles.space4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Row(
            children: [
              Text('Time Period:', style: AppStyles.labelMd),
              const SizedBox(width: AppStyles.space3),
              _buildPeriodChip('all', 'All Time'),
              const SizedBox(width: AppStyles.space2),
              _buildPeriodChip('today', 'Today'),
              const SizedBox(width: AppStyles.space2),
              _buildPeriodChip('week', 'Last 7 Days'),
              const SizedBox(width: AppStyles.space2),
              _buildPeriodChip('month', 'This Month'),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredInspections.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    icon: Icons.bar_chart,
                    title: 'No Data Available',
                    subtitle: 'No inspection data for the selected period',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppStyles.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary KPIs
                        ResponsiveGrid(
                          mobileColumns: 2,
                          tabletColumns: 3,
                          desktopColumns: 6,
                          spacing: AppStyles.space3,
                          children: [
                            _buildMetricCard(
                              'Total',
                              '${metrics['total']}',
                              Icons.assessment,
                              AppColors.primary,
                            ),
                            _buildMetricCard(
                              'Pass Rate',
                              '${metrics['pass_rate']}%',
                              Icons.check_circle,
                              AppColors.success,
                            ),
                            _buildMetricCard(
                              'Approved',
                              '${metrics['approved']}',
                              Icons.thumb_up,
                              AppColors.success,
                            ),
                            _buildMetricCard(
                              'Rejected',
                              '${metrics['rejected']}',
                              Icons.thumb_down,
                              AppColors.error,
                            ),
                            _buildMetricCard(
                              'Defects',
                              '${metrics['total_defects']}',
                              Icons.bug_report,
                              AppColors.warning,
                            ),
                            _buildMetricCard(
                              'Critical',
                              '${metrics['critical_defects']}',
                              Icons.error,
                              AppColors.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppStyles.space6),

                        // Status Breakdown
                        Text('Status Breakdown', style: AppStyles.headingSm),
                        const SizedBox(height: AppStyles.space3),
                        AppCard(
                          child: Column(
                            children: [
                              _buildProgressBar(
                                'Approved',
                                _statusBreakdown['approved'] ?? 0,
                                metrics['total'],
                                AppColors.success,
                              ),
                              const SizedBox(height: AppStyles.space3),
                              _buildProgressBar(
                                'Pending',
                                _statusBreakdown['pending'] ?? 0,
                                metrics['total'],
                                AppColors.warning,
                              ),
                              const SizedBox(height: AppStyles.space3),
                              _buildProgressBar(
                                'Rejected',
                                _statusBreakdown['rejected'] ?? 0,
                                metrics['total'],
                                AppColors.error,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppStyles.space6),

                        // Defects by Severity
                        Text('Defects by Severity', style: AppStyles.headingSm),
                        const SizedBox(height: AppStyles.space3),
                        ResponsiveGrid(
                          mobileColumns: 2,
                          tabletColumns: 4,
                          desktopColumns: 4,
                          spacing: AppStyles.space3,
                          children: [
                            _buildDefectCard(
                              'Critical',
                              _defectsBySeverity['critical'] ?? 0,
                              AppColors.error,
                              Icons.error,
                            ),
                            _buildDefectCard(
                              'Major',
                              _defectsBySeverity['major'] ?? 0,
                              AppColors.warning,
                              Icons.warning,
                            ),
                            _buildDefectCard(
                              'Minor',
                              _defectsBySeverity['minor'] ?? 0,
                              AppColors.info,
                              Icons.info,
                            ),
                            _buildDefectCard(
                              'Cosmetic',
                              _defectsBySeverity['cosmetic'] ?? 0,
                              AppColors.gray500,
                              Icons.palette,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppStyles.space6),

                        // Recent Inspections Timeline
                        Text('Recent Inspections', style: AppStyles.headingSm),
                        const SizedBox(height: AppStyles.space3),

                        ..._filteredInspections.take(10).map((inspection) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppStyles.space2,
                            ),
                            child: AppCard(
                              color: inspection.isApproved
                                  ? AppColors.success.withOpacity(0.1)
                                  : inspection.isRejected
                                  ? AppColors.error.withOpacity(0.1)
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    inspection.isApproved
                                        ? Icons.check_circle
                                        : inspection.isRejected
                                        ? Icons.cancel
                                        : Icons.pending,
                                    color: inspection.isApproved
                                        ? AppColors.success
                                        : inspection.isRejected
                                        ? AppColors.error
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: AppStyles.space3),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          inspection.productName,
                                          style: AppStyles.labelMd,
                                        ),
                                        Text(
                                          'Batch #${inspection.batchId}',
                                          style: AppStyles.bodyXs.copyWith(
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
                                        text: inspection.status.toUpperCase(),
                                        variant: inspection.isApproved
                                            ? BadgeVariant.success
                                            : inspection.isRejected
                                            ? BadgeVariant.danger
                                            : BadgeVariant.warning,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat(
                                          'MMM dd, HH:mm',
                                        ).format(inspection.inspectionDate),
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
                        }),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _timePeriod == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _timePeriod = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppStyles.space2),
          Text(value, style: AppStyles.headingMd.copyWith(color: color)),
          Text(
            label,
            style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppStyles.labelMd),
            Text(
              '$value / $total (${percentage.toStringAsFixed(1)}%)',
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.space2),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppStyles.radiusFull),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildDefectCard(String label, int count, Color color, IconData icon) {
    return AppCard(
      color: color.withOpacity(0.1),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppStyles.space2),
          Text('$count', style: AppStyles.headingLg.copyWith(color: color)),
          Text(label, style: AppStyles.labelMd, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
