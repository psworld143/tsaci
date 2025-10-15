import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../services/inventory_service.dart';
import '../../services/product_admin_service.dart';
import '../../models/inventory_model.dart';
import '../../models/product_model.dart';
import '../../utils/responsive.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final InventoryService _inventoryService = InventoryService();
  final ProductAdminService _productService = ProductAdminService();

  List<InventoryModel> _inventory = [];
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final inventory = _showLowStockOnly
          ? await _inventoryService.getLowStockItems()
          : await _inventoryService.getAllInventory();
      final products = await _productService.getAllProducts();

      setState(() {
        _inventory = inventory;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAdjustStockDialog(InventoryModel? item) async {
    final quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '0',
    );
    final locationController = TextEditingController(
      text: item?.location ?? 'Main Warehouse',
    );
    final thresholdController = TextEditingController(
      text: item?.minimumThreshold.toString() ?? '10',
    );
    int? selectedProductId = item?.productId;
    bool isLoading = false;
    final isNewItem = item == null;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusXl),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    gradient: isNewItem
                        ? AppColors.primaryGradient
                        : LinearGradient(
                            colors: [
                              AppColors.info,
                              AppColors.info.withOpacity(0.8),
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppStyles.radiusXl),
                      topRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.space4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isNewItem ? Icons.add_box : Icons.edit,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space3),
                      Text(
                        isNewItem ? 'Add Inventory' : 'Adjust Stock',
                        style: AppStyles.headingMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space1),
                      Text(
                        isNewItem
                            ? 'Add new stock to inventory'
                            : 'Update stock levels and settings',
                        style: AppStyles.bodySm.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content - Scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppStyles.space6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Selection (only for new items)
                        if (isNewItem) ...[
                          Text(
                            'Select Product',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space3),
                          DropdownButtonFormField<int>(
                            value: selectedProductId,
                            decoration: AppStyles.inputDecoration(
                              label: 'Product',
                              prefixIcon: Icons.inventory_2_outlined,
                            ),
                            hint: const Text('Select a product'),
                            items: _products.map((product) {
                              return DropdownMenuItem(
                                value: product.productId,
                                child: Text(product.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedProductId = value);
                            },
                          ),
                          const SizedBox(height: AppStyles.space6),
                        ],

                        // Stock Information
                        Text(
                          'Stock Information',
                          style: AppStyles.labelLg.copyWith(
                            color: isNewItem
                                ? AppColors.primary
                                : AppColors.info,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space3),
                        AppTextField(
                          controller: quantityController,
                          label: 'Quantity',
                          prefixIcon: Icons.inventory_outlined,
                          keyboardType: TextInputType.number,
                          hint: 'Enter quantity',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: locationController,
                          label: 'Location',
                          prefixIcon: Icons.location_on_outlined,
                          hint: 'e.g., Main Warehouse, Storage A',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: thresholdController,
                          label: 'Minimum Threshold',
                          prefixIcon: Icons.warning_amber_outlined,
                          keyboardType: TextInputType.number,
                          hint: 'Alert when stock falls below this',
                        ),
                        const SizedBox(height: AppStyles.space3),
                        Container(
                          padding: const EdgeInsets.all(AppStyles.space3),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusMd,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: AppStyles.space2),
                              Expanded(
                                child: Text(
                                  'You will be alerted when stock falls below the threshold',
                                  style: AppStyles.bodySm.copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppStyles.radiusXl),
                      bottomRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          variant: ButtonVariant.outline,
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(width: AppStyles.space3),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: isNewItem ? 'Add to Inventory' : 'Update Stock',
                          icon: isNewItem ? Icons.add : Icons.check,
                          loading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (quantityController.text.isEmpty ||
                                      locationController.text.isEmpty ||
                                      thresholdController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  final quantity = double.tryParse(
                                    quantityController.text,
                                  );
                                  final threshold = double.tryParse(
                                    thresholdController.text,
                                  );

                                  if (quantity == null || quantity < 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid quantity',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  if (threshold == null || threshold < 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid threshold',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    if (isNewItem) {
                                      // Create new inventory
                                      if (selectedProductId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please select a product',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                        setState(() => isLoading = false);
                                        return;
                                      }
                                      await _inventoryService.createInventory(
                                        productId: selectedProductId!,
                                        quantity: quantity,
                                        location: locationController.text,
                                        minimumThreshold: threshold,
                                      );
                                    } else {
                                      // Update existing inventory
                                      await _inventoryService.updateInventory(
                                        inventoryId: item.inventoryId,
                                        quantity: quantity,
                                        location: locationController.text,
                                        minimumThreshold: threshold,
                                      );
                                    }
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppStyles.space2),
                Text(
                  isNewItem
                      ? 'Inventory added successfully'
                      : 'Stock adjusted successfully',
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingState();
    }

    if (_error != null) {
      return AppErrorState(
        title: 'Error Loading Inventory',
        subtitle: _error!,
        onRetry: _loadData,
      );
    }

    final lowStockCount = _inventory.where((item) => item.isLowStock).length;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppStyles.space4,
            right: AppStyles.space4,
            top: AppStyles.space4,
            bottom: AppStyles.space20, // Extra bottom padding for FAB
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters
              Row(
                children: [
                  if (lowStockCount > 0)
                    AppBadge(
                      text:
                          '$lowStockCount Low Stock Alert${lowStockCount > 1 ? 's' : ''}',
                      variant: BadgeVariant.warning,
                    ),
                  const Spacer(),
                  AppButton(
                    text: _showLowStockOnly ? 'Show All' : 'Show Low Stock',
                    onPressed: () {
                      setState(() {
                        _showLowStockOnly = !_showLowStockOnly;
                      });
                      _loadData();
                    },
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.sm,
                    icon: _showLowStockOnly ? Icons.list : Icons.warning,
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.space4),

              // Inventory Grid
              if (_inventory.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppStyles.space6),
                    child: AppEmptyState(
                      icon: Icons.warehouse_outlined,
                      title: 'No Inventory Items',
                      subtitle: 'Add stock to get started',
                    ),
                  ),
                )
              else
                ResponsiveGrid(
                  mobileColumns: 1,
                  tabletColumns: 2,
                  desktopColumns: 3,
                  spacing: AppStyles.space3,
                  children: _inventory.map((item) {
                    return AppCard(
                      elevated: true,
                      border: item.isLowStock
                          ? Border.all(color: AppColors.warning, width: 2)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppStyles.space3),
                                decoration: BoxDecoration(
                                  color:
                                      (item.isLowStock
                                              ? AppColors.warning
                                              : AppColors.success)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppStyles.radiusMd,
                                  ),
                                ),
                                child: Icon(
                                  item.isLowStock
                                      ? Icons.warning
                                      : Icons.inventory,
                                  color: item.isLowStock
                                      ? AppColors.warning
                                      : AppColors.success,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppStyles.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: AppStyles.labelLg,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppStyles.space1),
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
                          const SizedBox(height: AppStyles.space3),
                          const Divider(),
                          const SizedBox(height: AppStyles.space3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stock Level',
                                    style: AppStyles.labelSm.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: AppStyles.headingSm.copyWith(
                                      color: item.isLowStock
                                          ? AppColors.warning
                                          : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Min. Threshold',
                                    style: AppStyles.labelSm.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${item.minimumThreshold}',
                                    style: AppStyles.bodySm,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppStyles.space2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppStyles.space1),
                              Text(
                                item.location,
                                style: AppStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (item.isLowStock) ...[
                            const SizedBox(height: AppStyles.space3),
                            Container(
                              padding: const EdgeInsets.all(AppStyles.space2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusSm,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    color: AppColors.warning,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppStyles.space2),
                                  Expanded(
                                    child: Text(
                                      'Low stock alert!',
                                      style: AppStyles.labelSm.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppStyles.space3),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'Adjust',
                                  onPressed: () => _showAdjustStockDialog(item),
                                  variant: ButtonVariant.secondary,
                                  size: ButtonSize.sm,
                                  icon: Icons.edit,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        // Floating Action Button
        Positioned(
          right: AppStyles.space4,
          bottom: AppStyles.space4,
          child: FloatingActionButton.extended(
            onPressed: () => _showAdjustStockDialog(null),
            icon: const Icon(Icons.add),
            label: const Text('Add Stock'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
