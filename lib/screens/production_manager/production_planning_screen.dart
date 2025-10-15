import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../utils/responsive.dart';
import '../../models/production_batch_model.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/batch_service.dart';
import '../../services/product_service.dart';
import '../../services/user_service.dart';

class ProductionPlanningScreen extends StatefulWidget {
  const ProductionPlanningScreen({Key? key}) : super(key: key);

  @override
  State<ProductionPlanningScreen> createState() =>
      _ProductionPlanningScreenState();
}

class _ProductionPlanningScreenState extends State<ProductionPlanningScreen> {
  final UserService _userService = UserService();
  List<ProductionBatch> _batches = [];
  List<ProductModel> _products = [];
  List<UserModel> _supervisors = [];
  List<UserModel> _workers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      print('[ProductionPlanning] Loading batches...');
      final batches = await BatchService.getAllBatches();
      print('[ProductionPlanning] Batches loaded: ${batches.length}');

      print('[ProductionPlanning] Loading products...');
      List<ProductModel> products = [];
      try {
        products = await ProductService.getAll();
        print('[ProductionPlanning] Products loaded: ${products.length}');
      } catch (e) {
        print('[ProductionPlanning] Products error (non-critical): $e');
        // Products optional - can still view batches without products
      }

      print('[ProductionPlanning] Loading users...');
      List<UserModel> allUsers = [];
      try {
        allUsers = await _userService.getAllUsers();
        print('[ProductionPlanning] Users loaded: ${allUsers.length}');
      } catch (e) {
        print('[ProductionPlanning] Users error (non-critical): $e');
        // Users optional - can still view batches
      }

      setState(() {
        _batches = batches
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
        _products = products;
        _supervisors = allUsers
            .where(
              (u) =>
                  u.role.toLowerCase() == 'production_manager' ||
                  u.role.toLowerCase() == 'manager',
            )
            .toList();
        _workers = allUsers
            .where(
              (u) =>
                  u.role.toLowerCase() == 'worker' ||
                  u.role.toLowerCase() == 'supervisor',
            )
            .toList();
        _isLoading = false;
      });

      print('[ProductionPlanning] Data loading complete');
      print('  - Batches: ${_batches.length}');
      print('  - Products: ${_products.length}');
      print('  - Supervisors: ${_supervisors.length}');
      print('  - Workers: ${_workers.length}');
    } catch (e) {
      print('[ProductionPlanning] Critical error loading data: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showBatchDialog({ProductionBatch? batch}) async {
    final isEdit = batch != null;

    // Controllers
    final batchNumberController = TextEditingController(
      text: batch?.batchNumber ?? '',
    );
    final quantityController = TextEditingController(
      text: batch?.targetQuantity.toString() ?? '',
    );
    final notesController = TextEditingController(text: batch?.notes ?? '');

    // State
    int? selectedProductId = batch?.productId;
    DateTime selectedDate = batch?.scheduledDate ?? DateTime.now();
    List<int> selectedSupervisorIds = List.from(batch?.supervisorIds ?? []);
    List<int> selectedWorkerIds = List.from(batch?.workerIds ?? []);
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusXl),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 750),
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
                          child: Icon(
                            isEdit ? Icons.edit : Icons.add_box,
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
                                isEdit ? 'Edit Batch' : 'Create New Batch',
                                style: AppStyles.headingMd.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppStyles.space1),
                              Text(
                                isEdit
                                    ? 'Update batch information'
                                    : 'Schedule a new production batch',
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
                          // Batch Information
                          Text(
                            'Batch Information',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space3),

                          // Batch Number
                          AppTextField(
                            controller: batchNumberController,
                            label: 'Batch Number',
                            prefixIcon: Icons.tag,
                            hint: 'Auto-generated if empty',
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Product Selection
                          Text(
                            'Product *',
                            style: AppStyles.labelMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space2),
                          DropdownButtonFormField<int>(
                            value: selectedProductId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.inventory_2),
                              hintText: 'Select product',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                              ),
                            ),
                            items: _products.map((product) {
                              return DropdownMenuItem(
                                value: product.productId,
                                child: Text(
                                  '${product.name} (${product.unit})',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedProductId = value;
                              });
                            },
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Target Quantity
                          AppTextField(
                            controller: quantityController,
                            label: 'Target Quantity',
                            prefixIcon: Icons.production_quantity_limits,
                            keyboardType: TextInputType.number,
                            hint: 'Enter target quantity',
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Scheduled Date
                          Text(
                            'Scheduled Date *',
                            style: AppStyles.labelMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space2),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setDialogState(() => selectedDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppStyles.space4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.gray300),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppStyles.space3),
                                  Text(
                                    DateFormat(
                                      'MMMM dd, yyyy',
                                    ).format(selectedDate),
                                    style: AppStyles.labelMd,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppStyles.space6),

                          // Supervisor Assignment
                          Text(
                            'Assign Supervisors',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space3),
                          if (_supervisors.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(AppStyles.space4),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppColors.warning,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: AppStyles.space2),
                                  Expanded(
                                    child: Text(
                                      'No supervisors available',
                                      style: AppStyles.bodySm,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._supervisors.map((supervisor) {
                              final isSelected = selectedSupervisorIds.contains(
                                supervisor.userId,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppStyles.space2,
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (checked) {
                                    setDialogState(() {
                                      if (checked == true) {
                                        selectedSupervisorIds.add(
                                          supervisor.userId,
                                        );
                                      } else {
                                        selectedSupervisorIds.remove(
                                          supervisor.userId,
                                        );
                                      }
                                    });
                                  },
                                  title: Text(supervisor.name),
                                  subtitle: Text(supervisor.email),
                                  secondary: Container(
                                    padding: const EdgeInsets.all(
                                      AppStyles.space2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppStyles.radiusSm,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.business_center,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppStyles.radiusMd,
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.gray300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  tileColor: isSelected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.05,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),

                          const SizedBox(height: AppStyles.space6),

                          // Worker Assignment
                          Text(
                            'Assign Workers',
                            style: AppStyles.labelLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppStyles.space3),
                          if (_workers.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(AppStyles.space4),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppColors.warning,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: AppStyles.space2),
                                  Expanded(
                                    child: Text(
                                      'No workers available',
                                      style: AppStyles.bodySm,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._workers.map((worker) {
                              final isSelected = selectedWorkerIds.contains(
                                worker.userId,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppStyles.space2,
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (checked) {
                                    setDialogState(() {
                                      if (checked == true) {
                                        selectedWorkerIds.add(worker.userId);
                                      } else {
                                        selectedWorkerIds.remove(worker.userId);
                                      }
                                    });
                                  },
                                  title: Text(worker.name),
                                  subtitle: Text(worker.email),
                                  secondary: Container(
                                    padding: const EdgeInsets.all(
                                      AppStyles.space2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppStyles.radiusSm,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.engineering,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppStyles.radiusMd,
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.info
                                          : AppColors.gray300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  tileColor: isSelected
                                      ? AppColors.info.withValues(alpha: 0.05)
                                      : null,
                                ),
                              );
                            }).toList(),

                          const SizedBox(height: AppStyles.space6),

                          // Notes
                          AppTextField(
                            controller: notesController,
                            label: 'Notes (Optional)',
                            prefixIcon: Icons.notes,
                            hint: 'Add any special instructions',
                            maxLines: 3,
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
                                : () => Navigator.pop(context),
                            variant: ButtonVariant.outline,
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: isEdit ? 'Update Batch' : 'Create Batch',
                            icon: Icons.check,
                            loading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () async {
                                    // Validation
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
                                      return;
                                    }

                                    if (quantityController.text.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter target quantity',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }

                                    final quantity = double.tryParse(
                                      quantityController.text,
                                    );
                                    if (quantity == null || quantity <= 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter a valid quantity',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }

                                    setDialogState(() => isLoading = true);

                                    try {
                                      final product = _products.firstWhere(
                                        (p) => p.productId == selectedProductId,
                                      );

                                      final supervisorNames = _supervisors
                                          .where(
                                            (s) => selectedSupervisorIds
                                                .contains(s.userId),
                                          )
                                          .map((s) => s.name)
                                          .toList();

                                      final workerNames = _workers
                                          .where(
                                            (w) => selectedWorkerIds.contains(
                                              w.userId,
                                            ),
                                          )
                                          .map((w) => w.name)
                                          .toList();

                                      // Prepare batch data
                                      final batchData = {
                                        'product_id': selectedProductId!,
                                        'target_quantity': quantity,
                                        'scheduled_date': selectedDate
                                            .toIso8601String()
                                            .split('T')[0],
                                        'status': batch?.status ?? 'planned',
                                        'current_stage':
                                            batch?.currentStage ?? 'mixing',
                                        'supervisor_ids': selectedSupervisorIds,
                                        'worker_ids': selectedWorkerIds,
                                        'notes': notesController.text.isEmpty
                                            ? null
                                            : notesController.text,
                                      };

                                      // Call API
                                      final result = isEdit
                                          ? await BatchService.updateBatch(
                                              batch!.batchId!,
                                              batchData,
                                            )
                                          : await BatchService.createBatch(
                                              batchData,
                                            );

                                      setDialogState(() => isLoading = false);

                                      if (mounted) {
                                        if (result['success'] == true) {
                                          Navigator.pop(context, true);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: AppStyles.space2,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      result['message'] ??
                                                          'Batch saved successfully',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  AppColors.success,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          _loadData();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                result['message'] ??
                                                    'Failed to save batch',
                                              ),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      setDialogState(() => isLoading = false);
                                      if (mounted) {
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
          );
        },
      ),
    );
  }

  Future<void> _deleteBatch(ProductionBatch batch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text(
          'Are you sure you want to delete batch ${batch.batchNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && batch.batchId != null) {
      try {
        final result = await BatchService.deleteBatch(batch.batchId!);
        if (mounted) {
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Batch deleted successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _loadData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to delete batch'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting batch: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
          ? const Center(
              child: AppEmptyState(
                icon: Icons.add_box,
                title: 'No Production Batches',
                subtitle: 'Create your first batch to get started',
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppStyles.space4,
                right: AppStyles.space4,
                top: AppStyles.space4,
                bottom: AppStyles.space20, // Space for FAB
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  ResponsiveGrid(
                    mobileColumns: 2,
                    tabletColumns: 4,
                    desktopColumns: 4,
                    spacing: AppStyles.space4,
                    children: [
                      StatCard(
                        title: 'Total Batches',
                        value: '${_batches.length}',
                        icon: Icons.inventory,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        title: 'Planned',
                        value:
                            '${_batches.where((b) => b.status == 'planned').length}',
                        icon: Icons.schedule,
                        color: AppColors.info,
                      ),
                      StatCard(
                        title: 'Ongoing',
                        value:
                            '${_batches.where((b) => b.status == 'ongoing').length}',
                        icon: Icons.hourglass_empty,
                        color: AppColors.warning,
                      ),
                      StatCard(
                        title: 'Completed',
                        value:
                            '${_batches.where((b) => b.status == 'completed').length}',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.space6),

                  // Batches List
                  Text(
                    'Production Batches (${_batches.length})',
                    style: AppStyles.headingSm,
                  ),
                  const SizedBox(height: AppStyles.space4),

                  ...List.generate(_batches.length, (index) {
                    final batch = _batches[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppStyles.space3),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        batch.batchNumber,
                                        style: AppStyles.labelLg,
                                      ),
                                      const SizedBox(height: AppStyles.space1),
                                      Text(
                                        batch.productName,
                                        style: AppStyles.bodySm.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppBadge(
                                  text: batch.statusDisplay,
                                  variant: _getStatusBadgeVariant(batch.status),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppStyles.space3),

                            // Details
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    Icons.production_quantity_limits,
                                    'Target',
                                    '${batch.targetQuantity} ${batch.unit}',
                                    AppColors.primary,
                                  ),
                                ),
                                Expanded(
                                  child: _buildInfoItem(
                                    Icons.calendar_today,
                                    'Scheduled',
                                    DateFormat(
                                      'MMM dd',
                                    ).format(batch.scheduledDate),
                                    AppColors.info,
                                  ),
                                ),
                                Expanded(
                                  child: _buildInfoItem(
                                    Icons.track_changes,
                                    'Stage',
                                    batch.stageDisplay,
                                    AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppStyles.space3),

                            // Team
                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppStyles.space2),
                                Expanded(
                                  child: Text(
                                    '${batch.supervisorNames.length} supervisors, ${batch.workerNames.length} workers',
                                    style: AppStyles.bodySm,
                                  ),
                                ),
                              ],
                            ),

                            if (batch.notes != null) ...[
                              const SizedBox(height: AppStyles.space3),
                              Container(
                                padding: const EdgeInsets.all(AppStyles.space2),
                                decoration: BoxDecoration(
                                  color: AppColors.gray50,
                                  borderRadius: BorderRadius.circular(
                                    AppStyles.radiusSm,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.note,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: AppStyles.space2),
                                    Expanded(
                                      child: Text(
                                        batch.notes!,
                                        style: AppStyles.bodyXs,
                                      ),
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
                                  onPressed: () =>
                                      _showBatchDialog(batch: batch),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                ),
                                const SizedBox(width: AppStyles.space2),
                                TextButton.icon(
                                  onPressed: () => _deleteBatch(batch),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBatchDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Batch'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildInfoItem(
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
        Text(value, style: AppStyles.labelMd),
      ],
    );
  }

  BadgeVariant _getStatusBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return BadgeVariant.info;
      case 'ongoing':
        return BadgeVariant.warning;
      case 'on_hold':
        return BadgeVariant.gray;
      case 'completed':
        return BadgeVariant.success;
      case 'cancelled':
        return BadgeVariant.danger;
      default:
        return BadgeVariant.gray;
    }
  }
}
