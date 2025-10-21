import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/stock_adjustment_model.dart';
import '../../models/inventory_model.dart';
import '../../services/stock_adjustment_service.dart';
import '../../services/inventory_service.dart';
import '../../services/auth_service.dart';
import '../../utils/export_helper.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({Key? key}) : super(key: key);

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<StockAdjustment> _adjustments = [];
  List<InventoryModel> _inventory = [];
  bool _isLoading = true;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final adjustments = await StockAdjustmentService.getAllAdjustments();
      final inventory = await _inventoryService.getAllInventory();

      setState(() {
        _adjustments = adjustments;
        _inventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<StockAdjustment> get _filteredAdjustments {
    if (_filterType == 'all') return _adjustments;
    return _adjustments
        .where((a) => a.adjustmentType.toLowerCase() == _filterType)
        .toList();
  }

  Future<void> _showAddAdjustmentDialog() async {
    int? selectedInventoryId;
    String adjustmentType = 'IN';
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedItem = selectedInventoryId != null
              ? _inventory.firstWhere(
                  (i) => i.inventoryId == selectedInventoryId,
                )
              : null;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusXl),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
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
                          AppColors.primary.withOpacity(0.8),
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.sync_alt,
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
                                'Record Stock Adjustment',
                                style: AppStyles.headingMd.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Track stock changes',
                                style: AppStyles.bodySm.copyWith(
                                  color: Colors.white.withOpacity(0.9),
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
                          // Product Selection
                          Text('Product *', style: AppStyles.labelMd),
                          const SizedBox(height: AppStyles.space2),
                          DropdownButtonFormField<int>(
                            value: selectedInventoryId,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.inventory),
                              hintText: 'Select product',
                              border: OutlineInputBorder(),
                            ),
                            items: _inventory.map((item) {
                              return DropdownMenuItem(
                                value: item.inventoryId,
                                child: Text(
                                  '${item.productName} (${item.quantity} available)',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedInventoryId = value;
                              });
                            },
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Adjustment Type
                          Text('Adjustment Type *', style: AppStyles.labelMd),
                          const SizedBox(height: AppStyles.space2),
                          Wrap(
                            spacing: AppStyles.space2,
                            runSpacing: AppStyles.space2,
                            children: [
                              _buildTypeChip(
                                'IN',
                                'Stock In',
                                Icons.arrow_downward,
                                AppColors.success,
                                adjustmentType,
                                (type) =>
                                    setDialogState(() => adjustmentType = type),
                              ),
                              _buildTypeChip(
                                'OUT',
                                'Stock Out',
                                Icons.arrow_upward,
                                AppColors.info,
                                adjustmentType,
                                (type) =>
                                    setDialogState(() => adjustmentType = type),
                              ),
                              _buildTypeChip(
                                'DAMAGE',
                                'Damaged',
                                Icons.broken_image,
                                AppColors.error,
                                adjustmentType,
                                (type) =>
                                    setDialogState(() => adjustmentType = type),
                              ),
                              _buildTypeChip(
                                'WASTE',
                                'Wastage',
                                Icons.delete,
                                AppColors.warning,
                                adjustmentType,
                                (type) =>
                                    setDialogState(() => adjustmentType = type),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Quantity
                          AppTextField(
                            controller: quantityController,
                            label: 'Quantity *',
                            prefixIcon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            hint: 'Enter quantity',
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Reason
                          AppTextField(
                            controller: reasonController,
                            label: 'Reason *',
                            prefixIcon: Icons.description,
                            hint: 'Enter reason for adjustment',
                            maxLines: 3,
                          ),

                          if (selectedItem != null) ...[
                            const SizedBox(height: AppStyles.space4),
                            Container(
                              padding: const EdgeInsets.all(AppStyles.space3),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Stock: ${selectedItem.quantity}',
                                    style: AppStyles.labelMd,
                                  ),
                                  if (quantityController.text.isNotEmpty)
                                    Text(
                                      _getAdjustmentPreview(
                                        selectedItem.quantity,
                                        double.tryParse(
                                              quantityController.text,
                                            ) ??
                                            0,
                                        adjustmentType,
                                      ),
                                      style: AppStyles.bodySm.copyWith(
                                        color: AppColors.info,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space6),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            variant: ButtonVariant.outline,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'Record Adjustment',
                            icon: Icons.check,
                            onPressed: () async {
                              if (selectedInventoryId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a product'),
                                  ),
                                );
                                return;
                              }

                              final quantity = double.tryParse(
                                quantityController.text,
                              );
                              if (quantity == null || quantity <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter valid quantity',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (reasonController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a reason'),
                                  ),
                                );
                                return;
                              }

                              try {
                                final currentUser =
                                    await AuthService.getCurrentUser();
                                final item = _inventory.firstWhere(
                                  (i) => i.inventoryId == selectedInventoryId,
                                );

                                // Record adjustment
                                await StockAdjustmentService.recordAdjustment(
                                  StockAdjustment(
                                    inventoryId: selectedInventoryId!,
                                    productName: item.productName,
                                    adjustmentType: adjustmentType,
                                    quantity: quantity,
                                    reason: reasonController.text,
                                    adjustedBy: currentUser?.userId ?? 0,
                                    adjustedByName: currentUser?.name ?? '',
                                    createdAt: DateTime.now(),
                                  ),
                                );

                                // Update actual inventory
                                double newQuantity;
                                if (adjustmentType == 'IN') {
                                  newQuantity = item.quantity + quantity;
                                } else {
                                  // OUT, DAMAGE, WASTE
                                  newQuantity = item.quantity - quantity;
                                }

                                if (newQuantity >= 0) {
                                  await _inventoryService.updateInventory(
                                    inventoryId: item.inventoryId,
                                    quantity: newQuantity,
                                    location: item.location,
                                    minimumThreshold: item.minimumThreshold,
                                  );
                                }

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Stock adjustment recorded successfully',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                _loadData();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
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

  String _getAdjustmentPreview(double current, double adjustment, String type) {
    if (type == 'IN') {
      return 'New stock: ${current + adjustment}';
    } else {
      return 'New stock: ${current - adjustment}';
    }
  }

  Widget _buildTypeChip(
    String value,
    String label,
    IconData icon,
    Color color,
    String currentValue,
    Function(String) onSelect,
  ) {
    final isSelected = currentValue == value;

    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.space3,
          vertical: AppStyles.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.gray50,
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppStyles.space2),
            Text(
              label,
              style: AppStyles.labelMd.copyWith(
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    try {
      final data = _filteredAdjustments
          .map(
            (adj) => {
              'Date': DateFormat('yyyy-MM-dd HH:mm').format(adj.createdAt),
              'Product': adj.productName,
              'Type': adj.typeDisplay,
              'Quantity': adj.quantity,
              'Reason': adj.reason,
              'Adjusted By': adj.adjustedByName,
            },
          )
          .toList();

      await ExportHelper.exportToCSV(data: data, filename: 'stock_adjustments');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adjustments exported successfully'),
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
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All', _adjustments.length),
                        const SizedBox(width: AppStyles.space2),
                        _buildFilterChip(
                          'in',
                          'Stock In',
                          _adjustments
                              .where((a) => a.adjustmentType == 'IN')
                              .length,
                        ),
                        const SizedBox(width: AppStyles.space2),
                        _buildFilterChip(
                          'out',
                          'Stock Out',
                          _adjustments
                              .where((a) => a.adjustmentType == 'OUT')
                              .length,
                        ),
                        const SizedBox(width: AppStyles.space2),
                        _buildFilterChip(
                          'damage',
                          'Damaged',
                          _adjustments
                              .where((a) => a.adjustmentType == 'DAMAGE')
                              .length,
                        ),
                        const SizedBox(width: AppStyles.space2),
                        _buildFilterChip(
                          'waste',
                          'Wastage',
                          _adjustments
                              .where((a) => a.adjustmentType == 'WASTE')
                              .length,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_filteredAdjustments.isNotEmpty) ...[
                  const SizedBox(width: AppStyles.space2),
                  AppButton(
                    text: 'Export',
                    icon: Icons.download,
                    onPressed: _handleExport,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAdjustments.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.sync_alt,
                      title: 'No Adjustments Yet',
                      subtitle: _filterType == 'all'
                          ? 'Record your first stock adjustment'
                          : 'No $_filterType adjustments found',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        left: AppStyles.space4,
                        right: AppStyles.space4,
                        top: AppStyles.space4,
                        bottom: AppStyles.space20,
                      ),
                      itemCount: _filteredAdjustments.length,
                      itemBuilder: (context, index) {
                        final adjustment = _filteredAdjustments[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppStyles.space3,
                          ),
                          child: _buildAdjustmentCard(adjustment),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdjustmentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Record Adjustment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildAdjustmentCard(StockAdjustment adjustment) {
    final color = _getTypeColor(adjustment.adjustmentType);
    final icon = _getTypeIcon(adjustment.adjustmentType);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(adjustment.productName, style: AppStyles.labelLg),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy hh:mm a',
                      ).format(adjustment.createdAt),
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: adjustment.typeDisplay,
                variant: _getTypeBadgeVariant(adjustment.adjustmentType),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space3),

          Row(
            children: [
              Icon(Icons.numbers, size: 16, color: color),
              const SizedBox(width: AppStyles.space2),
              Text(
                'Quantity: ${adjustment.quantity}',
                style: AppStyles.labelMd.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space2),

          Container(
            padding: const EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(AppStyles.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppStyles.space2),
                Expanded(
                  child: Text(adjustment.reason, style: AppStyles.bodyXs),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.space2),

          Row(
            children: [
              const Icon(
                Icons.person,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppStyles.space2),
              Text('By: ${adjustment.adjustedByName}', style: AppStyles.bodyXs),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'IN':
        return AppColors.success;
      case 'OUT':
        return AppColors.info;
      case 'DAMAGE':
        return AppColors.error;
      case 'WASTE':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'IN':
        return Icons.arrow_downward;
      case 'OUT':
        return Icons.arrow_upward;
      case 'DAMAGE':
        return Icons.broken_image;
      case 'WASTE':
        return Icons.delete;
      default:
        return Icons.sync_alt;
    }
  }

  BadgeVariant _getTypeBadgeVariant(String type) {
    switch (type.toUpperCase()) {
      case 'IN':
        return BadgeVariant.success;
      case 'OUT':
        return BadgeVariant.info;
      case 'DAMAGE':
        return BadgeVariant.danger;
      case 'WASTE':
        return BadgeVariant.warning;
      default:
        return BadgeVariant.gray;
    }
  }

  String get _filterStatus => _filterType;
}
