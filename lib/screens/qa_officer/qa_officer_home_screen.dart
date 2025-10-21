import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../services/quality_inspection_service.dart';

class QAOfficerHomeScreen extends StatefulWidget {
  const QAOfficerHomeScreen({Key? key}) : super(key: key);

  @override
  State<QAOfficerHomeScreen> createState() => _QAOfficerHomeScreenState();
}

class _QAOfficerHomeScreenState extends State<QAOfficerHomeScreen> {
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await QualityInspectionService.getStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      // Error handled silently for dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _stats['pending'] ?? 0;
    final approved = _stats['approved'] ?? 0;
    final rejected = _stats['rejected'] ?? 0;
    final total = _stats['total'] ?? 0;
    final passRate = _stats['pass_rate'] ?? '0.0';
    final totalDefects = _stats['total_defects'] ?? 0;
    final criticalDefects = _stats['critical_defects'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards - Primary Metrics
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 4,
            spacing: AppStyles.space4,
            children: [
              StatCard(
                title: 'Pending Tests',
                value: '$pending',
                icon: Icons.pending_actions,
                color: AppColors.warning,
                subtitle: 'Awaiting inspection',
              ),
              StatCard(
                title: 'Pass Rate',
                value: '$passRate%',
                icon: Icons.check_circle,
                color: AppColors.success,
                subtitle: 'Overall quality',
              ),
              StatCard(
                title: 'Total Defects',
                value: '$totalDefects',
                icon: Icons.bug_report,
                color: AppColors.error,
                subtitle: '$criticalDefects critical',
              ),
              StatCard(
                title: 'Inspections',
                value: '$total',
                icon: Icons.science,
                color: AppColors.primary,
                subtitle: 'Total logged',
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Secondary Metrics
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Approved',
                  value: '$approved',
                  icon: Icons.thumb_up,
                  color: AppColors.success,
                  subtitle: 'Passed tests',
                ),
              ),
              const SizedBox(width: AppStyles.space4),
              Expanded(
                child: StatCard(
                  title: 'Rejected',
                  value: '$rejected',
                  icon: Icons.thumb_down,
                  color: AppColors.error,
                  subtitle: 'Failed tests',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Alert Banner if there are pending inspections
          if (pending > 0) ...[
            AppCard(
              color: AppColors.warning.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppStyles.space4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space3),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                      ),
                      child: const Icon(
                        Icons.pending_actions,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppStyles.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Inspections',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            '$pending batches awaiting quality inspection',
                            style: AppStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: AppColors.warning),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space6),
          ],

          // Critical Defects Alert
          if (criticalDefects > 0) ...[
            AppCard(
              color: AppColors.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppStyles.space4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                      ),
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
                    const SizedBox(width: AppStyles.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Critical Defects',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          Text(
                            '$criticalDefects critical defects require immediate attention',
                            style: AppStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: AppColors.error),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space6),
          ],

          // Quick Actions
          Text('Quick Actions', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 4,
            desktopColumns: 4,
            spacing: AppStyles.space3,
            children: [
              _buildQuickAction(
                'Inspect Batch',
                Icons.science,
                AppColors.primary,
                () {},
              ),
              _buildQuickAction(
                'View Defects',
                Icons.bug_report,
                AppColors.error,
                () {},
              ),
              _buildQuickAction('Standards', Icons.rule, AppColors.info, () {}),
              _buildQuickAction(
                'Metrics',
                Icons.bar_chart,
                AppColors.success,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.space4),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppStyles.space2),
              Text(
                title,
                style: AppStyles.labelMd,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
