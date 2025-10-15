import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../manager/production_report_screen.dart';
import '../manager/sales_report_screen.dart';
import '../manager/expense_report_screen.dart';
import '../manager/inventory_report_screen.dart';
import 'performance_report_screen.dart';

class SystemReportsScreen extends StatelessWidget {
  final Function(String)? onNavigate;

  const SystemReportsScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Reports', style: AppStyles.headingLg),
          const SizedBox(height: AppStyles.space2),
          Text(
            'Select a report to view detailed analytics and insights',
            style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppStyles.space6),

          // Reports Grid
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            spacing: AppStyles.space4,
            children: [
              _buildReportCard(
                context: context,
                icon: Icons.factory,
                title: 'Production Report',
                description:
                    'View production logs, efficiency, and output metrics',
                color: AppColors.primary,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!('/admin/reports/production');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductionReportScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildReportCard(
                context: context,
                icon: Icons.point_of_sale,
                title: 'Sales Report',
                description: 'Analyze sales data, revenue, and customer orders',
                color: AppColors.success,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!('/admin/reports/sales');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SalesReportScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildReportCard(
                context: context,
                icon: Icons.receipt_long,
                title: 'Expense Report',
                description: 'Track expenses, categories, and spending trends',
                color: AppColors.error,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!('/admin/reports/expense');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseReportScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildReportCard(
                context: context,
                icon: Icons.warehouse,
                title: 'Inventory Report',
                description: 'Stock levels, alerts, and category distribution',
                color: AppColors.info,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!('/admin/reports/inventory');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InventoryReportScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildReportCard(
                context: context,
                icon: Icons.speed,
                title: 'Performance Report',
                description: 'System performance and efficiency metrics',
                color: AppColors.warning,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!('/admin/reports/performance');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerformanceReportScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Quick Stats Section
          Text('Report Categories', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),

          AppCard(
            child: Column(
              children: [
                _buildCategoryItem(
                  icon: Icons.business,
                  title: 'Operations',
                  description: 'Production and operational reports',
                  count: '1',
                ),
                const Divider(),
                _buildCategoryItem(
                  icon: Icons.attach_money,
                  title: 'Financial',
                  description: 'Sales and expense reports',
                  count: '2',
                ),
                const Divider(),
                _buildCategoryItem(
                  icon: Icons.inventory,
                  title: 'Inventory',
                  description: 'Stock levels and inventory analytics',
                  count: '1',
                ),
                const Divider(),
                _buildCategoryItem(
                  icon: Icons.speed,
                  title: 'Performance',
                  description: 'System performance and KPI tracking',
                  count: '1',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: AppStyles.space4),
          Text(title, style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space2),
          Text(
            description,
            style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppStyles.space4),
          Row(
            children: [
              Text(
                'View Report',
                style: AppStyles.labelSm.copyWith(color: color),
              ),
              const SizedBox(width: AppStyles.space1),
              Icon(Icons.arrow_forward, size: 16, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required String description,
    required String count,
    bool isComingSoon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.space2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.space3),
            decoration: BoxDecoration(
              color: isComingSoon
                  ? AppColors.gray200
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            ),
            child: Icon(
              icon,
              color: isComingSoon ? AppColors.textSecondary : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppStyles.labelMd),
                    if (isComingSoon) ...[
                      const SizedBox(width: AppStyles.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyles.space2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusFull,
                          ),
                        ),
                        child: Text(
                          'SOON',
                          style: AppStyles.labelSm.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppStyles.space1),
                Text(
                  description,
                  style: AppStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isComingSoon)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.space3,
                vertical: AppStyles.space2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppStyles.radiusFull),
              ),
              child: Text(
                count,
                style: AppStyles.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
