import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../services/sales_service.dart';
import '../../services/product_admin_service.dart';
import '../../models/sales_model.dart';
import '../../models/product_model.dart';
import '../../utils/responsive.dart';

class SalesManagementScreen extends StatefulWidget {
  const SalesManagementScreen({Key? key}) : super(key: key);

  @override
  State<SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends State<SalesManagementScreen> {
  final SalesService _salesService = SalesService();
  final ProductAdminService _productService = ProductAdminService();

  List<SalesModel> _sales = [];
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

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
      final sales = await _salesService.getAllSales();
      final products = await _productService.getAllProducts();

      setState(() {
        _sales = sales;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingState();
    }

    if (_error != null) {
      return AppErrorState(
        title: 'Error Loading Sales',
        subtitle: _error!,
        onRetry: _loadData,
      );
    }

    final totalSales = _sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );
    final pendingSales = _sales.where((s) => s.status == 'pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 3,
            desktopColumns: 3,
            spacing: AppStyles.space3,
            children: [
              StatCard(
                title: 'Total Sales',
                value: '₱${totalSales.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
              StatCard(
                title: 'Total Orders',
                value: '${_sales.length}',
                icon: Icons.shopping_cart,
                color: AppColors.info,
              ),
              StatCard(
                title: 'Pending Orders',
                value: '$pendingSales',
                icon: Icons.pending,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space6),

          // Sales List
          Text('Recent Sales', style: AppStyles.headingSm),
          const SizedBox(height: AppStyles.space4),

          if (_sales.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppStyles.space6),
                child: AppEmptyState(
                  icon: Icons.point_of_sale_outlined,
                  title: 'No Sales Records',
                  subtitle: 'Sales will appear here',
                ),
              ),
            )
          else
            ...List.generate(_sales.length, (index) {
              final sale = _sales[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppStyles.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sale.productName, style: AppStyles.labelLg),
                              const SizedBox(height: AppStyles.space1),
                              Text(
                                sale.customerName,
                                style: AppStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppBadge(
                          text: sale.status.toUpperCase(),
                          variant: _getStatusBadgeVariant(sale.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.space3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity',
                              style: AppStyles.labelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${sale.quantity} units',
                              style: AppStyles.bodySm,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Amount',
                              style: AppStyles.labelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₱${sale.totalAmount.toStringAsFixed(2)}',
                              style: AppStyles.headingSm.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.space2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppStyles.space1),
                        Text(
                          DateFormat('MMM d, y').format(sale.date),
                          style: AppStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  BadgeVariant _getStatusBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return BadgeVariant.success;
      case 'pending':
        return BadgeVariant.warning;
      case 'cancelled':
        return BadgeVariant.danger;
      default:
        return BadgeVariant.info;
    }
  }
}
