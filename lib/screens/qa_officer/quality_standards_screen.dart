import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/quality_standard_model.dart';
import '../../services/quality_standards_service.dart';

class QualityStandardsScreen extends StatefulWidget {
  const QualityStandardsScreen({Key? key}) : super(key: key);

  @override
  State<QualityStandardsScreen> createState() => _QualityStandardsScreenState();
}

class _QualityStandardsScreenState extends State<QualityStandardsScreen> {
  List<QualityStandard> _standards = [];
  bool _isLoading = true;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Initialize standards if empty
      await QualityStandardsService.initializeDefaults();

      final standards = await QualityStandardsService.getAllStandards();

      if (mounted) {
        setState(() {
          _standards = standards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  QualityStandard? get _selectedStandard {
    if (_selectedProductId == null) return null;

    try {
      return _standards.firstWhere((s) => s.productId == _selectedProductId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Product Selector
        Container(
          padding: const EdgeInsets.all(AppStyles.space4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Product', style: AppStyles.labelLg),
              const SizedBox(height: AppStyles.space3),
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Select a product to view standards',
                  border: OutlineInputBorder(),
                ),
                items: _standards.map((standard) {
                  return DropdownMenuItem(
                    value: standard.productId,
                    child: Text(standard.productName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedProductId = value);
                },
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _selectedStandard == null
              ? const Center(
                  child: AppEmptyState(
                    icon: Icons.rule,
                    title: 'Select a Product',
                    subtitle: 'Choose a product to view quality standards',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppStyles.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Header
                        AppCard(
                          color: AppColors.primary.withOpacity(0.1),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppStyles.space3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppStyles.radiusMd,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: AppStyles.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedStandard!.productName,
                                      style: AppStyles.headingMd,
                                    ),
                                    Text(
                                      'Quality Standards',
                                      style: AppStyles.bodySm.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppStyles.space6),

                        // Standards List
                        Text('Test Parameters', style: AppStyles.headingSm),
                        const SizedBox(height: AppStyles.space3),

                        ..._selectedStandard!.parameters.entries.map((entry) {
                          final param = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppStyles.space3,
                            ),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppStyles.space2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppStyles.radiusSm,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.science,
                                          color: AppColors.info,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: AppStyles.space2),
                                      Expanded(
                                        child: Text(
                                          param.parameterName,
                                          style: AppStyles.labelLg,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppStyles.space3),

                                  // Standard Range
                                  Container(
                                    padding: const EdgeInsets.all(
                                      AppStyles.space3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppStyles.radiusMd,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildRangeItem(
                                                'Minimum',
                                                '${param.minValue}',
                                                param.unit,
                                                AppColors.warning,
                                              ),
                                            ),
                                            Container(
                                              width: 2,
                                              height: 40,
                                              color: AppColors.gray300,
                                            ),
                                            Expanded(
                                              child: _buildRangeItem(
                                                'Maximum',
                                                '${param.maxValue}',
                                                param.unit,
                                                AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: AppStyles.space2,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: AppColors.success,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Acceptable Range: ${param.rangeText}',
                                              style: AppStyles.labelMd.copyWith(
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Visual Range Indicator
                                  const SizedBox(height: AppStyles.space3),
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.error,
                                                AppColors.success,
                                                AppColors.error,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppStyles.space1),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Below Standard',
                                        style: AppStyles.bodyXs.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                      Text(
                                        'Within Range',
                                        style: AppStyles.bodyXs.copyWith(
                                          color: AppColors.success,
                                        ),
                                      ),
                                      Text(
                                        'Above Standard',
                                        style: AppStyles.bodyXs.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Info Box
                        const SizedBox(height: AppStyles.space4),
                        Container(
                          padding: const EdgeInsets.all(AppStyles.space4),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info, color: AppColors.info),
                              const SizedBox(width: AppStyles.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About Quality Standards',
                                      style: AppStyles.labelMd.copyWith(
                                        color: AppColors.info,
                                      ),
                                    ),
                                    const SizedBox(height: AppStyles.space2),
                                    Text(
                                      'These standards define the acceptable quality ranges for each product. During inspection, measured values must fall within these ranges to pass quality control.',
                                      style: AppStyles.bodySm,
                                    ),
                                  ],
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
      ],
    );
  }

  Widget _buildRangeItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppStyles.bodyXs.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppStyles.headingSm.copyWith(color: color)),
            const SizedBox(width: 4),
            Text(
              unit,
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
