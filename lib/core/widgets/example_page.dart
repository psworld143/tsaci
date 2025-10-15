import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'widgets.dart';

/// EXAMPLE PAGE - Shows how to use the Tailwind-inspired UI components
/// Copy this file as a template for creating new pages
class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ScrollableAppScaffold(
      title: 'Example Page',
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      actions: [
        AppIconButton(icon: Icons.notifications, onPressed: () {}),
        const SizedBox(width: AppStyles.space2),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Row
          Text('Dashboard Stats', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Sales',
                  value: '₱125,400',
                  icon: Icons.attach_money,
                  color: AppColors.success,
                  subtitle: '+12%',
                ),
              ),
              const SizedBox(width: AppStyles.space4),
              Expanded(
                child: StatCard(
                  title: 'Production',
                  value: '850 kg',
                  icon: Icons.factory,
                  color: AppColors.primary,
                  subtitle: 'Today',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Buttons Section
          Text('Button Variants', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          AppCard(
            child: Column(
              children: [
                AppButton(
                  text: 'Primary Button',
                  onPressed: () {},
                  icon: Icons.add,
                  fullWidth: true,
                ),
                const SizedBox(height: AppStyles.space2),
                AppButton(
                  text: 'Success Button',
                  onPressed: () {},
                  variant: ButtonVariant.success,
                  fullWidth: true,
                ),
                const SizedBox(height: AppStyles.space2),
                AppButton(
                  text: 'Danger Button',
                  onPressed: () {},
                  variant: ButtonVariant.danger,
                  fullWidth: true,
                ),
                const SizedBox(height: AppStyles.space2),
                AppButton(
                  text: 'Outline Button',
                  onPressed: () {},
                  variant: ButtonVariant.outline,
                  fullWidth: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.space6),

          // Text Fields Section
          Text('Form Inputs', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          AppCard(
            child: Column(
              children: [
                const AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: AppStyles.space4),
                const AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: AppStyles.space4),
                const AppSearchField(hint: 'Search products...'),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.space6),

          // Badges Section
          Text('Status Badges', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          AppCard(
            child: Wrap(
              spacing: AppStyles.space2,
              runSpacing: AppStyles.space2,
              children: const [
                StatusBadge(status: 'Completed'),
                StatusBadge(status: 'Pending'),
                StatusBadge(status: 'Cancelled'),
                StatusBadge(status: 'Processing'),
                AppBadge(text: 'New', variant: BadgeVariant.info),
                AppBadge(text: 'Featured', variant: BadgeVariant.warning),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.space6),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Show Bottom Sheet',
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      title: 'Sample Bottom Sheet',
                      child: const Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  size: ButtonSize.sm,
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Expanded(
                child: AppButton(
                  text: 'Show Dialog',
                  onPressed: () {
                    AppConfirmDialog.show(
                      context: context,
                      title: 'Confirm Action',
                      message: 'Are you sure you want to proceed?',
                      isDanger: true,
                    );
                  },
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Loading State Example
          Text('States', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),
          AppCard(
            child: SizedBox(
              height: 200,
              child: _isLoading
                  ? const AppLoadingState(message: 'Loading data...')
                  : const AppEmptyState(
                      icon: Icons.inbox,
                      title: 'No data yet',
                      subtitle: 'Start by adding some items',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
