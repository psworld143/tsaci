import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../models/material_withdrawal_model.dart';
import '../../models/inventory_model.dart';
import '../../services/material_withdrawal_service.dart';
import '../../services/inventory_service.dart';
import '../../services/auth_service.dart';

class MaterialUsageScreen extends StatefulWidget {
  const MaterialUsageScreen({Key? key}) : super(key: key);

  @override
  State<MaterialUsageScreen> createState() => _MaterialUsageScreenState();
}

class _MaterialUsageScreenState extends State<MaterialUsageScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<MaterialWithdrawal> _withdrawals = [];
  List<MaterialWithdrawal> _selectedWithdrawals = [];
  List<InventoryModel> _inventory = [];
  bool _isLoading = true;
  String _filterStatus = 'pending';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      print('[MaterialUsage] Loading withdrawals...');
      final withdrawals = await MaterialWithdrawalService.getAllWithdrawals();
      print('[MaterialUsage] Withdrawals loaded: ${withdrawals.length}');

      print('[MaterialUsage] Loading inventory...');
      final inventory = await _inventoryService.getAllInventory();
      print('[MaterialUsage] Inventory loaded: ${inventory.length}');

      setState(() {
        _withdrawals = withdrawals
          ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
        _inventory = inventory;
        _isLoading = false;
      });

      print('[MaterialUsage] Data loading complete');
    } catch (e) {
      print('[MaterialUsage] Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<MaterialWithdrawal> get _filteredWithdrawals {
    var filtered = _withdrawals
        .where((w) => w.status.toLowerCase() == _filterStatus)
        .toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((w) {
        return w.productName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            w.requestedByName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            w.purpose.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Future<void> _handleBulkApprove() async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Approve'),
        content: Text(
          'Approve ${_selectedWithdrawals.length} material withdrawal${_selectedWithdrawals.length > 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      int successCount = 0;
      int failedCount = 0;

      for (var withdrawal in _selectedWithdrawals) {
        try {
          if (withdrawal.withdrawalId != null) {
            await MaterialWithdrawalService.approveWithdrawal(
              withdrawal.withdrawalId!,
              currentUser.userId,
            );
            successCount++;
          }
        } catch (e) {
          failedCount++;
        }
      }

      setState(() => _selectedWithdrawals.clear());
      _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Approved $successCount request${successCount > 1 ? 's' : ''}' +
                  (failedCount > 0 ? ', $failedCount failed' : ''),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _approveWithdrawal(MaterialWithdrawal withdrawal) async {
    try {
      print('[MaterialUsage] Approving withdrawal #${withdrawal.withdrawalId}');

      // Get current user
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check inventory
      final item = _inventory.firstWhere(
        (i) => i.inventoryId == withdrawal.inventoryId,
        orElse: () => throw Exception('Inventory item not found'),
      );

      if (item.quantity < withdrawal.requestedQuantity) {
        throw Exception(
          'Insufficient stock: Available ${item.quantity}, Requested ${withdrawal.requestedQuantity} ${withdrawal.unit}',
        );
      }

      // Show confirmation
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Approve Withdrawal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${withdrawal.productName}'),
              Text(
                'Quantity: ${withdrawal.requestedQuantity} ${withdrawal.unit}',
              ),
              Text('Requested by: ${withdrawal.requestedByName}'),
              const SizedBox(height: AppStyles.space4),
              Container(
                padding: const EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.warning),
                    const SizedBox(width: AppStyles.space2),
                    Expanded(
                      child: Text(
                        'This will deduct ${withdrawal.requestedQuantity} ${withdrawal.unit} from inventory',
                        style: AppStyles.bodySm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Approve'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final response = await MaterialWithdrawalService.approveWithdrawal(
          withdrawal.withdrawalId!,
          currentUser.userId,
        );

        if (mounted) {
          if (response['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: AppStyles.space2),
                    Text(
                      response['message'] ??
                          'Withdrawal approved & stock deducted',
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _loadData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ?? 'Failed to approve withdrawal',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('[MaterialUsage] Error approving withdrawal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectWithdrawal(MaterialWithdrawal withdrawal) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${withdrawal.productName}'),
            Text(
              'Quantity: ${withdrawal.requestedQuantity} ${withdrawal.unit}',
            ),
            const SizedBox(height: AppStyles.space4),
            AppTextField(
              controller: reasonController,
              label: 'Rejection Reason *',
              prefixIcon: Icons.comment,
              hint: 'Enter reason for rejection',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final currentUser = await AuthService.getCurrentUser();
        if (currentUser == null) throw Exception('User not authenticated');

        final response = await MaterialWithdrawalService.rejectWithdrawal(
          withdrawal.withdrawalId!,
          currentUser.userId,
          reasonController.text,
        );

        if (mounted) {
          if (response['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Withdrawal rejected'),
                backgroundColor: AppColors.error,
              ),
            );
            _loadData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ?? 'Failed to reject withdrawal',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error rejecting: $e')));
        }
      }
    }
  }

  Future<void> _createWithdrawalRequest() async {
    int? selectedInventoryId;
    final quantityController = TextEditingController();
    final purposeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusXl),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                          AppColors.primary.withValues(alpha: 0.8),
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
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
                                'Create Withdrawal Request',
                                style: AppStyles.headingMd.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Request materials from inventory',
                                style: AppStyles.bodySm.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
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
                          // Material Selection
                          Text(
                            'Select Material *',
                            style: AppStyles.labelMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space2),
                          DropdownButtonFormField<int>(
                            value: selectedInventoryId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.inventory),
                              hintText: 'Select material',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                              ),
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

                          // Quantity
                          AppTextField(
                            controller: quantityController,
                            label: 'Quantity *',
                            prefixIcon: Icons.production_quantity_limits,
                            keyboardType: TextInputType.number,
                            hint: 'Enter quantity',
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Purpose
                          AppTextField(
                            controller: purposeController,
                            label: 'Purpose *',
                            prefixIcon: Icons.description,
                            hint: 'e.g., Batch #PB-2025-001, Maintenance, etc.',
                            maxLines: 2,
                          ),

                          if (selectedInventoryId != null) ...[
                            const SizedBox(height: AppStyles.space4),
                            Container(
                              padding: const EdgeInsets.all(AppStyles.space3),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: AppStyles.space2),
                                  Expanded(
                                    child: Text(
                                      'Available: ${_inventory.firstWhere((i) => i.inventoryId == selectedInventoryId).quantity}',
                                      style: AppStyles.bodySm,
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
                            onPressed: () => Navigator.pop(context),
                            variant: ButtonVariant.outline,
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'Create Request',
                            icon: Icons.send,
                            onPressed: () async {
                              // Validation
                              if (selectedInventoryId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a material'),
                                  ),
                                );
                                return;
                              }

                              if (quantityController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter quantity'),
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

                              if (purposeController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter purpose'),
                                  ),
                                );
                                return;
                              }

                              try {
                                final currentUser =
                                    await AuthService.getCurrentUser();

                                final withdrawalData = {
                                  'inventory_id': selectedInventoryId!,
                                  'requested_quantity': quantity,
                                  'requested_by': currentUser?.userId ?? 0,
                                  'purpose': purposeController.text,
                                };

                                final response =
                                    await MaterialWithdrawalService.createWithdrawal(
                                      withdrawalData,
                                    );

                                if (mounted) {
                                  if (response['success'] == true) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response['message'] ??
                                              'Withdrawal request created successfully',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    _loadData();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response['message'] ??
                                              'Failed to create request',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingWithdrawals = _selectedWithdrawals
        .where((w) => w.status == 'pending')
        .toList();

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by product, requester, or purpose...',
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
          ),

          // Filter Bar
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                _buildFilterChip(
                  'pending',
                  'Pending',
                  _withdrawals.where((w) => w.status == 'pending').length,
                ),
                const SizedBox(width: AppStyles.space2),
                _buildFilterChip(
                  'approved',
                  'Approved',
                  _withdrawals.where((w) => w.status == 'approved').length,
                ),
                const SizedBox(width: AppStyles.space2),
                _buildFilterChip(
                  'rejected',
                  'Rejected',
                  _withdrawals.where((w) => w.status == 'rejected').length,
                ),
              ],
            ),
          ),

          // Bulk Operations (only for pending)
          if (_selectedWithdrawals.isNotEmpty && _filterStatus == 'pending')
            Padding(
              padding: const EdgeInsets.all(AppStyles.space4),
              child: BulkOperationsWidget(
                selectedCount: pendingWithdrawals.length,
                onSelectAll: () {
                  setState(() {
                    _selectedWithdrawals = _filteredWithdrawals
                        .where((w) => w.status == 'pending')
                        .toList();
                  });
                },
                onDeselectAll: () {
                  setState(() => _selectedWithdrawals.clear());
                },
                customActions: [
                  AppButton(
                    text: 'Approve Selected',
                    onPressed: pendingWithdrawals.isNotEmpty
                        ? _handleBulkApprove
                        : null,
                    icon: Icons.check_circle,
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
                : _filteredWithdrawals.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.inventory_2,
                      title: 'No Requests Found',
                      subtitle: _filterStatus == 'pending'
                          ? 'No pending material withdrawal requests'
                          : 'No $_filterStatus requests',
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
                      itemCount: _filteredWithdrawals.length,
                      itemBuilder: (context, index) {
                        final withdrawal = _filteredWithdrawals[index];
                        final isSelected = _selectedWithdrawals.contains(
                          withdrawal,
                        );
                        final canSelect = withdrawal.status == 'pending';

                        if (!canSelect) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppStyles.space3,
                            ),
                            child: _buildWithdrawalCard(withdrawal),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppStyles.space3,
                          ),
                          child: SelectableListTile(
                            isSelected: isSelected,
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedWithdrawals.add(withdrawal);
                                } else {
                                  _selectedWithdrawals.remove(withdrawal);
                                }
                              });
                            },
                            child: _buildWithdrawalCard(withdrawal),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createWithdrawalRequest,
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.gray300,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildWithdrawalCard(MaterialWithdrawal withdrawal) {
    final isPending = withdrawal.status == 'pending';

    // Check inventory availability
    final inventoryItem = _inventory.firstWhere(
      (i) => i.inventoryId == withdrawal.inventoryId,
      orElse: () => InventoryModel(
        inventoryId: 0,
        productId: 0,
        productName: 'Unknown',
        category: '',
        quantity: 0,
        location: '',
        minimumThreshold: 0,
      ),
    );
    final hasStock = inventoryItem.quantity >= withdrawal.requestedQuantity;

    return AppCard(
      border: !hasStock && isPending
          ? Border.all(color: AppColors.error, width: 2)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space3),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    withdrawal.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Icon(
                  _getStatusIcon(withdrawal.status),
                  color: _getStatusColor(withdrawal.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(withdrawal.productName, style: AppStyles.labelLg),
                    Text(
                      withdrawal.category,
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: withdrawal.status.toUpperCase(),
                variant: _getStatusBadgeVariant(withdrawal.status),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space4),

          // Details Grid
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 3,
            spacing: AppStyles.space3,
            children: [
              _buildDetailItem(
                Icons.production_quantity_limits,
                'Requested',
                '${withdrawal.requestedQuantity} ${withdrawal.unit}',
                _getStatusColor(withdrawal.status),
              ),
              _buildDetailItem(
                Icons.inventory,
                'Available',
                '${inventoryItem.quantity}',
                hasStock ? AppColors.success : AppColors.error,
              ),
              _buildDetailItem(
                Icons.calendar_today,
                'Date',
                DateFormat('MMM dd').format(withdrawal.requestedAt),
                AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space3),

          // Requested By
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppStyles.space2),
              Text(
                'Requested by: ${withdrawal.requestedByName}',
                style: AppStyles.bodySm,
              ),
            ],
          ),

          // Batch Info
          if (withdrawal.batchNumber != null) ...[
            const SizedBox(height: AppStyles.space2),
            Row(
              children: [
                const Icon(Icons.tag, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppStyles.space2),
                Text(
                  'Batch: ${withdrawal.batchNumber}',
                  style: AppStyles.bodySm,
                ),
              ],
            ),
          ],

          // Purpose
          const SizedBox(height: AppStyles.space3),
          Container(
            padding: const EdgeInsets.all(AppStyles.space3),
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
                  child: Text(withdrawal.purpose, style: AppStyles.bodyXs),
                ),
              ],
            ),
          ),

          // Stock Warning
          if (!hasStock && isPending) ...[
            const SizedBox(height: AppStyles.space3),
            Container(
              padding: const EdgeInsets.all(AppStyles.space3),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.error),
                  const SizedBox(width: AppStyles.space2),
                  Expanded(
                    child: Text(
                      'Insufficient stock! Only ${inventoryItem.quantity} available.',
                      style: AppStyles.bodySm.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Approval Info
          if (!isPending) ...[
            const SizedBox(height: AppStyles.space3),
            Container(
              padding: const EdgeInsets.all(AppStyles.space3),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  withdrawal.status,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(withdrawal.status),
                        size: 14,
                        color: _getStatusColor(withdrawal.status),
                      ),
                      const SizedBox(width: AppStyles.space2),
                      Text(
                        withdrawal.status == 'approved'
                            ? 'Approved by ${withdrawal.approvedByName}'
                            : 'Rejected by ${withdrawal.approvedByName}',
                        style: AppStyles.bodyXs,
                      ),
                    ],
                  ),
                  if (withdrawal.approvedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy hh:mm a',
                      ).format(withdrawal.approvedAt!),
                      style: AppStyles.bodyXs.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (withdrawal.rejectionReason != null) ...[
                    const SizedBox(height: AppStyles.space2),
                    Text(
                      'Reason: ${withdrawal.rejectionReason}',
                      style: AppStyles.bodyXs.copyWith(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Actions for pending requests
          if (isPending) ...[
            const SizedBox(height: AppStyles.space3),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: hasStock
                      ? () => _approveWithdrawal(withdrawal)
                      : null,
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Approve'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
                TextButton.icon(
                  onPressed: () => _rejectWithdrawal(withdrawal),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.labelMd.copyWith(color: color)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  BadgeVariant _getStatusBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BadgeVariant.warning;
      case 'approved':
        return BadgeVariant.success;
      case 'rejected':
        return BadgeVariant.danger;
      default:
        return BadgeVariant.gray;
    }
  }
}
