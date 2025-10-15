import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart';
import '../../services/storage_service.dart';
import '../../services/offline/offline_storage_service.dart';
import '../../services/offline/sync_service.dart';
import '../../core/constants/api_constants.dart';

class AddProductionScreen extends StatefulWidget {
  const AddProductionScreen({Key? key}) : super(key: key);

  @override
  State<AddProductionScreen> createState() => _AddProductionScreenState();
}

class _AddProductionScreenState extends State<AddProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputQtyController = TextEditingController();
  final _outputQtyController = TextEditingController();
  final _notesController = TextEditingController();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingProducts = true;
  int? _selectedProductId;
  DateTime _selectedDate = DateTime.now();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _inputQtyController.dispose();
    _outputQtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await SyncService.isOnline();
    setState(() => _isOnline = isOnline);
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.getAll();
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supervisorId = await StorageService.getUserId();

      if (supervisorId == null) {
        throw Exception('User not authenticated');
      }

      final productionData = {
        'product_id': _selectedProductId,
        'supervisor_id': supervisorId,
        'input_qty': double.parse(_inputQtyController.text),
        'output_qty': double.parse(_outputQtyController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'location': 'Main Warehouse',
      };

      // Check if online
      final isOnline = await SyncService.isOnline();

      if (isOnline) {
        // Try to submit online
        try {
          await ApiService.post(ApiConstants.production, productionData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Production log added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          }
        } catch (e) {
          // If online submission fails, save offline
          await OfflineStorageService.saveProductionOffline(productionData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved offline. Will sync when connected.'),
                backgroundColor: AppColors.warning,
              ),
            );
            Navigator.pop(context, true);
          }
        }
      } else {
        // Save offline directly
        await OfflineStorageService.saveProductionOffline(productionData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved offline. Will sync when online.'),
              backgroundColor: AppColors.warning,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add Production Log',
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.space4,
                vertical: AppStyles.space4,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connection Status
                    AppCard(
                      color: _isOnline
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(
                            _isOnline ? Icons.cloud_done : Icons.cloud_off,
                            color: _isOnline
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: AppStyles.space2),
                          Text(
                            _isOnline
                                ? 'Online - Data will be synced immediately'
                                : 'Offline - Data will be saved locally',
                            style: AppStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppStyles.space6),

                    // Product Selection
                    Text('Product Information', style: AppStyles.headingSm),
                    const SizedBox(height: AppStyles.space4),
                    AppCard(
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedProductId,
                            decoration: AppStyles.inputDecoration(
                              label: 'Select Product',
                              prefixIcon: Icons.category,
                            ),
                            items: _products
                                .map(
                                  (product) => DropdownMenuItem(
                                    value: product.productId,
                                    child: Text(product.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedProductId = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a product';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppStyles.space4),
                          AppTextField(
                            label: 'Production Date',
                            hint: DateFormat(
                              'MMMM dd, yyyy',
                            ).format(_selectedDate),
                            prefixIcon: Icons.calendar_today,
                            readOnly: true,
                            onTap: _selectDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppStyles.space6),

                    // Raw Materials (Input)
                    Text('Raw Materials Used', style: AppStyles.headingSm),
                    const SizedBox(height: AppStyles.space4),
                    AppCard(
                      child: AppTextField(
                        label: 'Input Quantity (kg)',
                        hint: 'Enter raw material quantity',
                        controller: _inputQtyController,
                        prefixIcon: Icons.arrow_downward,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter input quantity';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Quantity must be greater than 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppStyles.space6),

                    // Output Products
                    Text('Output Products', style: AppStyles.headingSm),
                    const SizedBox(height: AppStyles.space4),
                    AppCard(
                      child: AppTextField(
                        label: 'Output Quantity (kg)',
                        hint: 'Enter output quantity',
                        controller: _outputQtyController,
                        prefixIcon: Icons.arrow_upward,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter output quantity';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Quantity must be greater than 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppStyles.space6),

                    // Notes
                    Text('Additional Notes', style: AppStyles.headingSm),
                    const SizedBox(height: AppStyles.space4),
                    AppCard(
                      child: AppTextField(
                        label: 'Notes (Optional)',
                        hint: 'Add any additional information...',
                        controller: _notesController,
                        prefixIcon: Icons.note,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: AppStyles.space8),

                    // Submit Button
                    AppButton(
                      text: _isOnline ? 'Submit' : 'Save Offline',
                      icon: _isOnline ? Icons.send : Icons.save,
                      onPressed: _isLoading ? null : _handleSubmit,
                      loading: _isLoading,
                      fullWidth: true,
                      size: ButtonSize.lg,
                    ),
                    const SizedBox(height: AppStyles.space2),
                    AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      variant: ButtonVariant.outline,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
