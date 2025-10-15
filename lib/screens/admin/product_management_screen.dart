import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../services/product_admin_service.dart';
import '../../models/product_model.dart';
import '../../utils/responsive.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductAdminService _productService = ProductAdminService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.getAllProducts();
      setState(() {
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

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController();
    bool isLoading = false;

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
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
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
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space3),
                      Text(
                        'Add New Product',
                        style: AppStyles.headingMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space1),
                      Text(
                        'Create a new product in the inventory',
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
                        Text(
                          'Product Information',
                          style: AppStyles.labelLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space3),
                        AppTextField(
                          controller: nameController,
                          label: 'Product Name',
                          prefixIcon: Icons.inventory_2_outlined,
                          hint: 'Enter product name',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: categoryController,
                          label: 'Category',
                          prefixIcon: Icons.category_outlined,
                          hint: 'e.g., Raw Material, Finished Goods',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: priceController,
                          label: 'Price (₱)',
                          prefixIcon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          hint: '0.00',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: unitController,
                          label: 'Unit of Measurement',
                          prefixIcon: Icons.straighten,
                          hint: 'e.g., kg, pcs, box, liter',
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
                          text: 'Add Product',
                          icon: Icons.add,
                          loading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (nameController.text.isEmpty ||
                                      categoryController.text.isEmpty ||
                                      priceController.text.isEmpty ||
                                      unitController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  final price = double.tryParse(
                                    priceController.text,
                                  );
                                  if (price == null || price <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid price',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    await _productService.createProduct(
                                      name: nameController.text,
                                      category: categoryController.text,
                                      price: price,
                                      unit: unitController.text,
                                    );
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
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppStyles.space2),
                Text('Product added successfully'),
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

  Future<void> _showEditProductDialog(ProductModel product) async {
    final nameController = TextEditingController(text: product.name);
    final categoryController = TextEditingController(text: product.category);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final unitController = TextEditingController(text: product.unit);
    bool isLoading = false;

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
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
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
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space3),
                      Text(
                        'Edit Product',
                        style: AppStyles.headingMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space1),
                      Text(
                        'Update product information',
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
                        Text(
                          'Product Information',
                          style: AppStyles.labelLg.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space3),
                        AppTextField(
                          controller: nameController,
                          label: 'Product Name',
                          prefixIcon: Icons.inventory_2_outlined,
                          hint: 'Enter product name',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: categoryController,
                          label: 'Category',
                          prefixIcon: Icons.category_outlined,
                          hint: 'e.g., Raw Material, Finished Goods',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: priceController,
                          label: 'Price (₱)',
                          prefixIcon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          hint: '0.00',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: unitController,
                          label: 'Unit of Measurement',
                          prefixIcon: Icons.straighten,
                          hint: 'e.g., kg, pcs, box, liter',
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
                          text: 'Update Product',
                          icon: Icons.check,
                          loading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (nameController.text.isEmpty ||
                                      categoryController.text.isEmpty ||
                                      priceController.text.isEmpty ||
                                      unitController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  final price = double.tryParse(
                                    priceController.text,
                                  );
                                  if (price == null || price <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid price',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    await _productService.updateProduct(
                                      productId: product.productId,
                                      name: nameController.text,
                                      category: categoryController.text,
                                      price: price,
                                      unit: unitController.text,
                                    );
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
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppStyles.space2),
                Text('Product updated successfully'),
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

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        ),
        child: Container(
          width: 450,
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header with red gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppStyles.space6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
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
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppStyles.space3),
                    Text(
                      'Delete Product',
                      style: AppStyles.headingMd.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppStyles.space1),
                    Text(
                      'This action cannot be undone',
                      style: AppStyles.bodySm.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppStyles.space6),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppStyles.space2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppStyles.radiusSm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: AppColors.error,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppStyles.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: AppStyles.labelLg,
                                    ),
                                    Text(
                                      product.category,
                                      style: AppStyles.bodySm.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '₱${product.price.toStringAsFixed(2)} / ${product.unit}',
                                      style: AppStyles.labelSm.copyWith(
                                        color: AppColors.success,
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
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: AppStyles.space2),
                              Expanded(
                                child: Text(
                                  'Are you sure you want to delete this product?',
                                  style: AppStyles.labelMd.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      flex: 2,
                      child: AppButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context, false),
                        variant: ButtonVariant.outline,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: AppStyles.space3),
                    Expanded(
                      child: AppButton(
                        text: 'Delete',
                        icon: Icons.delete,
                        onPressed: () => Navigator.pop(context, true),
                        variant: ButtonVariant.danger,
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
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.productId);
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: AppStyles.space2),
                  Text('Product deleted successfully'),
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              ),
            ),
          );
        }
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
        title: 'Error Loading Products',
        subtitle: _error!,
        onRetry: _loadProducts,
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.space6),
          child: AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No Products Found',
            subtitle: 'Add your first product to get started',
          ),
        ),
      );
    }

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
              // Products Grid
              ResponsiveGrid(
                mobileColumns: 1,
                tabletColumns: 2,
                desktopColumns: 3,
                spacing: AppStyles.space3,
                children: _products.map((product) {
                  return AppCard(
                    elevated: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppStyles.space3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusMd,
                                ),
                              ),
                              child: const Icon(
                                Icons.inventory_2,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppStyles.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppStyles.labelLg,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppStyles.space1),
                                  Text(
                                    product.category,
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
                                  'Price',
                                  style: AppStyles.labelSm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '₱${product.price.toStringAsFixed(2)}',
                                  style: AppStyles.headingSm.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppStyles.space2,
                                vertical: AppStyles.space1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppStyles.radiusSm,
                                ),
                              ),
                              child: Text(
                                product.unit,
                                style: AppStyles.labelSm.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppStyles.space3),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Edit',
                                onPressed: () =>
                                    _showEditProductDialog(product),
                                variant: ButtonVariant.secondary,
                                size: ButtonSize.sm,
                                icon: Icons.edit,
                              ),
                            ),
                            const SizedBox(width: AppStyles.space2),
                            AppIconButton(
                              icon: Icons.delete,
                              onPressed: () => _deleteProduct(product),
                              tooltip: 'Delete',
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
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
