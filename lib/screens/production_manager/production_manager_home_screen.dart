import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';

class ProductionManagerHomeScreen extends StatefulWidget {
  const ProductionManagerHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProductionManagerHomeScreen> createState() =>
      _ProductionManagerHomeScreenState();
}

class _ProductionManagerHomeScreenState
    extends State<ProductionManagerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 4,
            spacing: AppStyles.space4,
            children: [
              StatCard(
                title: 'Active Batches',
                value: '8',
                icon: Icons.inventory,
                color: AppColors.primary,
                subtitle: '2 pending approval',
              ),
              StatCard(
                title: 'Today\'s Production',
                value: '1,245 kg',
                icon: Icons.factory,
                color: AppColors.success,
                subtitle: '85% of target',
              ),
              StatCard(
                title: 'Workers Active',
                value: '24',
                icon: Icons.people,
                color: AppColors.info,
                subtitle: '3 teams',
              ),
              StatCard(
                title: 'Material Requests',
                value: '5',
                icon: Icons.pending_actions,
                color: AppColors.warning,
                subtitle: 'Pending approval',
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

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
                'New Batch',
                Icons.add_box,
                AppColors.primary,
                () {},
              ),
              _buildQuickAction(
                'Approve Materials',
                Icons.check_circle,
                AppColors.success,
                () {},
              ),
              _buildQuickAction(
                'View Batches',
                Icons.list_alt,
                AppColors.info,
                () {},
              ),
              _buildQuickAction(
                'Reports',
                Icons.assessment,
                AppColors.warning,
                () {},
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Recent Activity
          Text('Recent Activity', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          AppCard(
            child: Column(
              children: [
                _buildActivityItem(
                  'Batch #PB-2024-001 moved to QA stage',
                  '10 minutes ago',
                  Icons.arrow_forward,
                  AppColors.primary,
                ),
                const Divider(),
                _buildActivityItem(
                  'Material request approved for Batch #PB-2024-003',
                  '25 minutes ago',
                  Icons.check_circle,
                  AppColors.success,
                ),
                const Divider(),
                _buildActivityItem(
                  'Worker feedback added by Supervisor John',
                  '1 hour ago',
                  Icons.comment,
                  AppColors.info,
                ),
                const Divider(),
                _buildActivityItem(
                  'Batch #PB-2024-002 completed and dispatched',
                  '2 hours ago',
                  Icons.local_shipping,
                  AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppStyles.space3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppStyles.space2),
            Text(label, style: AppStyles.labelMd, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.space3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.labelMd),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppStyles.bodyXs.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
