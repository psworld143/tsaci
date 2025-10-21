import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/inventory_model.dart';
import '../../services/inventory_service.dart';
import '../../utils/export_helper.dart';

class ReorderManagementScreen extends StatefulWidget {
  const ReorderManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReorderManagementScreen> createState() =>
      _ReorderManagementScreenState();
}

class _ReorderManagementScreenState extends State<ReorderManagementScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryModel> _lowStockItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLowStock();
  }

  Future<void> _loadLowStock() async {
    setState(() => _isLoading = true);

    try {
      final inventory = await _inventoryService.getLowStockItems();
      setState(() {
        _lowStockItems = inventory
          ..sort((a, b) {
            final aDeficit = a.minimumThreshold - a.quantity;
            final bDeficit = b.minimumThreshold - b.quantity;
            return bDeficit.compareTo(aDeficit);
          });
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportReorderList() async {
    try {
      final data = _lowStockItems.map((item) {
        final deficit = item.minimumThreshold - item.quantity;
        return {
          'Product': item.productName,
          'Category': item.category,
          'Current Stock': item.quantity,
          'Minimum Required': item.minimumThreshold,
          'Shortage': deficit,
          'Suggested Order': (deficit * 1.5).toStringAsFixed(
            0,
          ), // 150% of deficit
          'Location': item.location,
        };
      }).toList();

      await ExportHelper.exportToCSV(data: data, filename: 'reorder_list');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reorder list exported successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.all(AppStyles.space6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: AppColors.warning)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space3),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppStyles.space4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reorder Required',
                            style: AppStyles.headingMd.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            '${_lowStockItems.length} items below minimum stock',
                            style: AppStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.space4),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Export Reorder List',
                        icon: Icons.download,
                        onPressed: _lowStockItems.isNotEmpty
                            ? _exportReorderList
                            : null,
                        variant: ButtonVariant.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _lowStockItems.isEmpty
                ? const Center(
                    child: AppEmptyState(
                      icon: Icons.check_circle,
                      title: 'All Stock Levels Healthy',
                      subtitle: 'No items below minimum threshold',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLowStock,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      itemCount: _lowStockItems.length,
                      itemBuilder: (context, index) {
                        final item = _lowStockItems[index];
                        final deficit = item.minimumThreshold - item.quantity;
                        final suggestedOrder = (deficit * 1.5).toStringAsFixed(
                          0,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppStyles.space3,
                          ),
                          child: AppCard(
                            border: Border.all(
                              color: AppColors.warning,
                              width: 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                        AppStyles.space3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppStyles.radiusMd,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.warning,
                                        color: AppColors.warning,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppStyles.space3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: AppStyles.labelLg,
                                          ),
                                          Text(
                                            item.category,
                                            style: AppStyles.bodySm.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppStyles.space4),
                                const Divider(),
                                const SizedBox(height: AppStyles.space3),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetric(
                                        'Current',
                                        '${item.quantity}',
                                        AppColors.error,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMetric(
                                        'Minimum',
                                        '${item.minimumThreshold}',
                                        AppColors.warning,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMetric(
                                        'Shortage',
                                        '${deficit.toStringAsFixed(0)}',
                                        AppColors.error,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMetric(
                                        'Suggested Order',
                                        suggestedOrder,
                                        AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppStyles.space3),
                                Container(
                                  padding: const EdgeInsets.all(
                                    AppStyles.space2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppStyles.radiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: AppColors.info,
                                      ),
                                      const SizedBox(width: AppStyles.space2),
                                      Text(
                                        'Location: ${item.location}',
                                        style: AppStyles.bodyXs,
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppStyles.labelMd.copyWith(color: color)),
      ],
    );
  }
}
