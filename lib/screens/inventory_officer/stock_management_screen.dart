import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/inventory_model.dart';
import '../../services/inventory_service.dart';
import '../../utils/export_helper.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({Key? key}) : super(key: key);

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryModel> _inventory = [];
  List<InventoryModel> _selectedItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterCategory = 'all';
  String _filterStockStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final inventory = await _inventoryService.getAllInventory();

      setState(() {
        _inventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  List<InventoryModel> get _filteredInventory {
    var filtered = _inventory;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.productName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Category filter
    if (_filterCategory != 'all') {
      filtered = filtered
          .where((item) => item.category == _filterCategory)
          .toList();
    }

    // Stock status filter
    if (_filterStockStatus == 'low') {
      filtered = filtered.where((item) => item.isLowStock).toList();
    } else if (_filterStockStatus == 'healthy') {
      filtered = filtered.where((item) => !item.isLowStock).toList();
    }

    return filtered;
  }

  Set<String> get _categories {
    return _inventory.map((i) => i.category).toSet();
  }

  Future<void> _showUpdateStockDialog(InventoryModel item) async {
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final thresholdController = TextEditingController(
      text: item.minimumThreshold.toString(),
    );
    final locationController = TextEditingController(text: item.location);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppStyles.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    child: const Icon(Icons.edit, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Update Stock', style: AppStyles.labelLg),
                        Text(
                          item.productName,
                          style: AppStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.space6),

              // Quantity
              AppTextField(
                controller: quantityController,
                label: 'Current Quantity',
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppStyles.space4),

              // Minimum Threshold
              AppTextField(
                controller: thresholdController,
                label: 'Minimum Threshold',
                prefixIcon: Icons.warning,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppStyles.space4),

              // Location
              AppTextField(
                controller: locationController,
                label: 'Location',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: AppStyles.space6),

              // Actions
              Row(
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
                      text: 'Update',
                      icon: Icons.check,
                      onPressed: () async {
                        final quantity = double.tryParse(
                          quantityController.text,
                        );
                        final threshold = double.tryParse(
                          thresholdController.text,
                        );

                        if (quantity == null || threshold == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid numbers'),
                            ),
                          );
                          return;
                        }

                        try {
                          await _inventoryService.updateInventory(
                            inventoryId: item.inventoryId,
                            quantity: quantity,
                            location: locationController.text,
                            minimumThreshold: threshold,
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stock updated successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadData();
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    final format = await BulkActionsDialog.showExportDialog(context);

    if (format == 'csv') {
      try {
        final data = _filteredInventory
            .map(
              (item) => {
                'Product': item.productName,
                'Category': item.category,
                'Quantity': item.quantity,
                'Location': item.location,
                'Min Threshold': item.minimumThreshold,
                'Status': item.isLowStock ? 'Low Stock' : 'In Stock',
              },
            )
            .toList();

        await ExportHelper.exportToCSV(
          data: data,
          filename: 'inventory_export',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inventory exported successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Column(
              children: [
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by product, category, or location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusLg),
                    ),
                    filled: true,
                    fillColor: AppColors.gray50,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: AppStyles.space3),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('All Categories'),
                          ),
                          ..._categories.map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _filterCategory = value ?? 'all');
                        },
                      ),
                    ),
                    const SizedBox(width: AppStyles.space2),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStockStatus,
                        decoration: const InputDecoration(
                          labelText: 'Stock Status',
                          prefixIcon: Icon(Icons.filter_list),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                            value: 'low',
                            child: Text('Low Stock'),
                          ),
                          DropdownMenuItem(
                            value: 'healthy',
                            child: Text('Healthy'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _filterStockStatus = value ?? 'all');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bulk Operations & Export
          if (_selectedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppStyles.space4),
              child: BulkOperationsWidget(
                selectedCount: _selectedItems.length,
                onSelectAll: () {
                  setState(() {
                    _selectedItems = List.from(_filteredInventory);
                  });
                },
                onDeselectAll: () {
                  setState(() => _selectedItems.clear());
                },
                onExport: _handleExport,
              ),
            )
          else if (_filteredInventory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppStyles.space4),
              child: Row(
                children: [
                  Text(
                    '${_filteredInventory.length} items',
                    style: AppStyles.labelMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'Export',
                    icon: Icons.download,
                    onPressed: _handleExport,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredInventory.isEmpty
                ? const Center(
                    child: AppEmptyState(
                      icon: Icons.inventory,
                      title: 'No Items Found',
                      subtitle: 'No inventory items match your filters',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      itemCount: _filteredInventory.length,
                      itemBuilder: (context, index) {
                        final item = _filteredInventory[index];
                        final isSelected = _selectedItems.contains(item);

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppStyles.space3,
                          ),
                          child: SelectableListTile(
                            isSelected: isSelected,
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedItems.add(item);
                                } else {
                                  _selectedItems.remove(item);
                                }
                              });
                            },
                            child: _buildInventoryCard(item),
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

  Widget _buildInventoryCard(InventoryModel item) {
    return AppCard(
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
                      (item.isLowStock ? AppColors.warning : AppColors.success)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Icon(
                  item.isLowStock ? Icons.warning : Icons.inventory,
                  color: item.isLowStock
                      ? AppColors.warning
                      : AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: AppStyles.labelLg),
                    Text(
                      '${item.category} • ${item.location}',
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity}',
                    style: AppStyles.headingSm.copyWith(
                      color: item.isLowStock
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                  Text(
                    'Min: ${item.minimumThreshold}',
                    style: AppStyles.bodyXs.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (item.isLowStock) ...[
            const SizedBox(height: AppStyles.space3),
            Container(
              padding: const EdgeInsets.all(AppStyles.space2),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: AppColors.warning),
                  const SizedBox(width: AppStyles.space2),
                  Text(
                    'LOW STOCK ALERT',
                    style: AppStyles.labelSm.copyWith(color: AppColors.warning),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppStyles.space3),
          const Divider(),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showUpdateStockDialog(item),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Update'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
