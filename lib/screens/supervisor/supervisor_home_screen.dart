import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/app_drawer.dart';
import '../../utils/responsive.dart';
import '../../services/auth_service.dart';
import '../../services/offline/offline_storage_service.dart';
import '../../services/offline/sync_service.dart';
import 'add_production_screen.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  String _userName = '';
  int _offlineCount = 0;
  bool _isOnline = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.getCurrentUser();
    final offlineCount = await OfflineStorageService.getOfflineCount();
    final isOnline = await SyncService.isOnline();

    if (mounted) {
      setState(() {
        _userName = user?.name ?? '';
        _offlineCount = offlineCount;
        _isOnline = isOnline;
      });
    }
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);

    try {
      final result = await SyncService.syncOfflineData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Synced: ${result.success} success, ${result.failed} failed',
            ),
            backgroundColor: result.hasFailures
                ? AppColors.warning
                : AppColors.success,
          ),
        );

        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Supervisor Panel',
      showBackButton: false,
      drawer: const AppDrawer(userRole: 'supervisor'),
      actions: [
        if (_offlineCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.space2),
            child: Center(
              child: AppBadge(
                text: '$_offlineCount offline',
                variant: BadgeVariant.warning,
              ),
            ),
          ),
        const SizedBox(width: AppStyles.space2),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.space4,
          vertical: AppStyles.space4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: _isOnline ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: AppStyles.space1),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: AppStyles.bodySm.copyWith(
                    color: _isOnline ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.space6),

            // Sync Status
            if (_offlineCount > 0) ...[
              AppCard(
                color: AppColors.warning.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.cloud_upload,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppStyles.space2),
                        Expanded(
                          child: Text(
                            'Pending Sync',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        if (_isOnline)
                          AppButton(
                            text: 'Sync Now',
                            onPressed: _isSyncing ? null : _handleSync,
                            loading: _isSyncing,
                            variant: ButtonVariant.warning,
                            size: ButtonSize.sm,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.space2),
                    Text(
                      '$_offlineCount production log(s) waiting to sync',
                      style: AppStyles.bodySm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.space6),
            ],

            // Quick Actions
            Text('Quick Actions', style: AppStyles.headingSm),
            const SizedBox(height: AppStyles.space4),

            // Add Production Button
            AppCard(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductionScreen(),
                  ),
                );
                _loadData();
              },
              elevated: true,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    child: const Icon(
                      Icons.add_circle,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppStyles.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Production Log', style: AppStyles.labelLg),
                        const SizedBox(height: AppStyles.space1),
                        Text(
                          'Record daily production data',
                          style: AppStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            const SizedBox(height: AppStyles.space4),

            // Info Cards
            ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 2,
              spacing: AppStyles.space4,
              children: [
                StatCard(
                  title: 'Raw Materials',
                  value: 'Track',
                  icon: Icons.inventory,
                  color: AppColors.info,
                ),
                StatCard(
                  title: 'Output Products',
                  value: 'Record',
                  icon: Icons.output,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppStyles.space6),

            // Instructions
            Text('Instructions', style: AppStyles.headingSm),
            const SizedBox(height: AppStyles.space4),
            AppCard(
              color: AppColors.info.withOpacity(0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionItem('1', 'Record production data daily'),
                  const SizedBox(height: AppStyles.space2),
                  _buildInstructionItem(
                    '2',
                    'Data saves offline if no connection',
                  ),
                  const SizedBox(height: AppStyles.space2),
                  _buildInstructionItem('3', 'Sync automatically when online'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppStyles.labelSm.copyWith(color: AppColors.textLight),
            ),
          ),
        ),
        const SizedBox(width: AppStyles.space2),
        Expanded(child: Text(text, style: AppStyles.bodySm)),
      ],
    );
  }
}
