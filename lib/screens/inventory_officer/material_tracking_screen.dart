import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/material_withdrawal_model.dart';
import '../../services/material_withdrawal_service.dart';
import '../../utils/export_helper.dart';

class MaterialTrackingScreen extends StatefulWidget {
  const MaterialTrackingScreen({Key? key}) : super(key: key);

  @override
  State<MaterialTrackingScreen> createState() => _MaterialTrackingScreenState();
}

class _MaterialTrackingScreenState extends State<MaterialTrackingScreen> {
  List<MaterialWithdrawal> _withdrawals = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<void> _loadWithdrawals() async {
    setState(() => _isLoading = true);

    try {
      final withdrawals = await MaterialWithdrawalService.getAllWithdrawals();
      setState(() {
        _withdrawals = withdrawals
          ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<MaterialWithdrawal> get _filteredWithdrawals {
    var filtered = _filterStatus == 'all'
        ? _withdrawals
        : _withdrawals.where((w) => w.status == _filterStatus).toList();

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

  Future<void> _handleExport() async {
    try {
      final data = _filteredWithdrawals
          .map(
            (w) => {
              'Date': DateFormat('yyyy-MM-dd HH:mm').format(w.requestedAt),
              'Product': w.productName,
              'Quantity': '${w.requestedQuantity} ${w.unit}',
              'Requested By': w.requestedByName,
              'Purpose': w.purpose,
              'Status': w.status.toUpperCase(),
              if (w.approvedByName != null) 'Approved By': w.approvedByName!,
            },
          )
          .toList();

      await ExportHelper.exportToCSV(
        data: data,
        filename: 'material_withdrawals',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material withdrawals exported successfully'),
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
    final totalWithdrawals = _withdrawals.length;
    final pending = _withdrawals.where((w) => w.status == 'pending').length;
    final approved = _withdrawals.where((w) => w.status == 'approved').length;

    return Scaffold(
      body: Column(
        children: [
          // Summary Bar
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryStat(
                    'Total',
                    totalWithdrawals,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildSummaryStat(
                    'Pending',
                    pending,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildSummaryStat(
                    'Approved',
                    approved,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search withdrawals...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyles.radiusLg),
                      ),
                      filled: true,
                      fillColor: AppColors.gray50,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: AppStyles.space2),
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

          // Filter Chips
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter('all', 'All'),
                  const SizedBox(width: AppStyles.space2),
                  _buildStatusFilter('pending', 'Pending'),
                  const SizedBox(width: AppStyles.space2),
                  _buildStatusFilter('approved', 'Approved'),
                  const SizedBox(width: AppStyles.space2),
                  _buildStatusFilter('rejected', 'Rejected'),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWithdrawals.isEmpty
                ? const Center(
                    child: AppEmptyState(
                      icon: Icons.sync_alt,
                      title: 'No Withdrawals Found',
                      subtitle: 'No material withdrawals match your filters',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadWithdrawals,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      itemCount: _filteredWithdrawals.length,
                      itemBuilder: (context, index) {
                        final withdrawal = _filteredWithdrawals[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppStyles.space3,
                          ),
                          child: _buildWithdrawalCard(withdrawal),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: AppStyles.headingMd.copyWith(color: color)),
        Text(label, style: AppStyles.bodySm),
      ],
    );
  }

  Widget _buildStatusFilter(String value, String label) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildWithdrawalCard(MaterialWithdrawal withdrawal) {
    final color = _getStatusColor(withdrawal.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(withdrawal.productName, style: AppStyles.labelLg),
                    Text(
                      '${withdrawal.requestedQuantity} ${withdrawal.unit}',
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
          const SizedBox(height: AppStyles.space3),

          Text('Purpose: ${withdrawal.purpose}', style: AppStyles.bodySm),
          const SizedBox(height: AppStyles.space2),

          Row(
            children: [
              const Icon(
                Icons.person,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Requested by: ${withdrawal.requestedByName}',
                style: AppStyles.bodyXs,
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd').format(withdrawal.requestedAt),
                style: AppStyles.bodyXs.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (withdrawal.approvedByName != null) ...[
            const SizedBox(height: AppStyles.space2),
            Text(
              '${withdrawal.status == 'approved' ? 'Approved' : 'Rejected'} by: ${withdrawal.approvedByName}',
              style: AppStyles.bodyXs.copyWith(color: color),
            ),
          ],
        ],
      ),
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
