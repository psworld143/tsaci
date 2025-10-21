import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../models/inventory_model.dart';
import '../../services/inventory_service.dart';

class InventoryOfficerHomeScreen extends StatefulWidget {
  const InventoryOfficerHomeScreen({Key? key}) : super(key: key);

  @override
  State<InventoryOfficerHomeScreen> createState() =>
      _InventoryOfficerHomeScreenState();
}

class _InventoryOfficerHomeScreenState
    extends State<InventoryOfficerHomeScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryModel> _inventory = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      final inventory = await _inventoryService.getAllInventory();
      if (mounted) {
        setState(() {
          _inventory = inventory;
        });
      }
    } catch (e) {
      // Error handled silently for dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _inventory.length;
    final lowStockItems = _inventory.where((i) => i.isLowStock).length;
    final totalQuantity = _inventory.fold<double>(
      0,
      (sum, i) => sum + i.quantity,
    );
    final categories = _inventory.map((i) => i.category).toSet().length;

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
                title: 'Total Items',
                value: '$totalItems',
                icon: Icons.inventory,
                color: AppColors.primary,
                subtitle: 'In system',
              ),
              StatCard(
                title: 'Low Stock Alerts',
                value: '$lowStockItems',
                icon: Icons.warning,
                color: AppColors.warning,
                subtitle: 'Need attention',
              ),
              StatCard(
                title: 'Total Quantity',
                value: '${totalQuantity.toStringAsFixed(0)} kg',
                icon: Icons.scale,
                color: AppColors.info,
                subtitle: 'All materials',
              ),
              StatCard(
                title: 'Categories',
                value: '$categories',
                icon: Icons.category,
                color: AppColors.success,
                subtitle: 'Product types',
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Low Stock Alert
          if (lowStockItems > 0) ...[
            AppCard(
              color: AppColors.warning.withOpacity(0.1),
              child: InkWell(
                onTap: () {
                  // Navigate to reorder screen
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.space4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.space3),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusMd,
                          ),
                        ),
                        child: const Icon(Icons.warning, color: Colors.white),
                      ),
                      const SizedBox(width: AppStyles.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Low Stock Alert',
                              style: AppStyles.labelLg.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                            Text(
                              '$lowStockItems items below minimum threshold',
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
                'Update Stock',
                Icons.edit,
                AppColors.primary,
                () {},
              ),
              _buildQuickAction(
                'Adjustments',
                Icons.sync_alt,
                AppColors.info,
                () {},
              ),
              _buildQuickAction(
                'Material Requests',
                Icons.list_alt,
                AppColors.warning,
                () {},
              ),
              _buildQuickAction(
                'Reorder List',
                Icons.shopping_cart,
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
