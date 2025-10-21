import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/production_model.dart';
import '../../models/quality_inspection_model.dart';
import '../../services/production_service.dart';
import '../../services/quality_inspection_service.dart';
import '../../services/quality_standards_service.dart';
import '../../services/auth_service.dart';

class BatchInspectionScreen extends StatefulWidget {
  const BatchInspectionScreen({Key? key}) : super(key: key);

  @override
  State<BatchInspectionScreen> createState() => _BatchInspectionScreenState();
}

class _BatchInspectionScreenState extends State<BatchInspectionScreen> {
  List<Production> _batches = [];
  List<QualityInspection> _inspections = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final batches = await ProductionService.getAll(limit: 50);
      final inspections = await QualityInspectionService.getAllInspections();

      if (mounted) {
        setState(() {
          _batches = batches;
          _inspections = inspections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Production> get _filteredBatches {
    if (_filterStatus == 'all') {
      return _batches;
    } else if (_filterStatus == 'pending') {
      // Show batches without inspection
      return _batches.where((batch) {
        return !_inspections.any((insp) => insp.batchId == batch.productionId);
      }).toList();
    } else if (_filterStatus == 'inspected') {
      // Show batches with inspection
      return _batches.where((batch) {
        return _inspections.any((insp) => insp.batchId == batch.productionId);
      }).toList();
    }
    return _batches;
  }

  QualityInspection? _getInspectionForBatch(int batchId) {
    try {
      return _inspections.firstWhere((insp) => insp.batchId == batchId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _showInspectionDialog(Production batch) async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return;

    // Get existing inspection or create new
    final existingInspection = _getInspectionForBatch(batch.productionId);

    // Get quality standards for this product
    final standard = await QualityStandardsService.getByProductId(
      batch.productId,
    );

    // Initialize test results
    Map<String, TestResult> tests = {};

    if (existingInspection != null) {
      tests = existingInspection.tests;
    } else if (standard != null) {
      // Create default tests from standards
      tests = standard.parameters.map(
        (key, range) => MapEntry(
          key,
          TestResult(
            testName: key,
            measuredValue: 0,
            minStandard: range.minValue,
            maxStandard: range.maxValue,
            unit: range.unit,
            passed: false,
          ),
        ),
      );
    } else {
      // Create default generic tests
      tests = {
        'pH Level': TestResult(
          testName: 'pH Level',
          measuredValue: 0,
          minStandard: 6.0,
          maxStandard: 8.0,
          unit: 'pH',
          passed: false,
        ),
        'Moisture Content': TestResult(
          testName: 'Moisture Content',
          measuredValue: 0,
          minStandard: 0,
          maxStandard: 5,
          unit: '%',
          passed: false,
        ),
        'Ash Content': TestResult(
          testName: 'Ash Content',
          measuredValue: 0,
          minStandard: 0,
          maxStandard: 5,
          unit: '%',
          passed: false,
        ),
      };
    }

    // Controllers for test values
    final controllers = <String, TextEditingController>{};
    for (var key in tests.keys) {
      controllers[key] = TextEditingController(
        text: tests[key]!.measuredValue > 0
            ? tests[key]!.measuredValue.toString()
            : '',
      );
    }

    final remarksController = TextEditingController(
      text: existingInspection?.remarks ?? '',
    );

    List<Defect> defects = existingInspection?.defects ?? [];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Recalculate test results based on current values
          for (var key in tests.keys) {
            final value = double.tryParse(controllers[key]!.text) ?? 0;
            final test = tests[key]!;
            tests[key] = TestResult(
              testName: test.testName,
              measuredValue: value,
              minStandard: test.minStandard,
              maxStandard: test.maxStandard,
              unit: test.unit,
              passed: value >= test.minStandard && value <= test.maxStandard,
            );
          }

          final allTestsPassed = tests.values.every((test) => test.passed);

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
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppStyles.radiusXl),
                        topRight: Radius.circular(AppStyles.radiusXl),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                Icons.science,
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
                                    'Quality Inspection',
                                    style: AppStyles.headingMd.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Batch #${batch.productionId}',
                                    style: AppStyles.bodySm.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppStyles.space3),
                        Text(
                          batch.productName ?? 'Unknown Product',
                          style: AppStyles.labelLg.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Quantity: ${batch.outputQty} kg • ${DateFormat('MMM dd, yyyy').format(DateTime.parse(batch.date))}',
                          style: AppStyles.bodySm.copyWith(
                            color: Colors.white.withOpacity(0.9),
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
                          // Quality Tests
                          Text('Quality Tests', style: AppStyles.headingSm),
                          const SizedBox(height: AppStyles.space3),

                          ...tests.entries.map((entry) {
                            final test = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppStyles.space3,
                              ),
                              child: AppCard(
                                color: test.passed && test.measuredValue > 0
                                    ? AppColors.success.withOpacity(0.1)
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          test.passed && test.measuredValue > 0
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color:
                                              test.passed &&
                                                  test.measuredValue > 0
                                              ? AppColors.success
                                              : AppColors.gray400,
                                        ),
                                        const SizedBox(width: AppStyles.space2),
                                        Expanded(
                                          child: Text(
                                            test.testName,
                                            style: AppStyles.labelMd,
                                          ),
                                        ),
                                        if (test.measuredValue > 0)
                                          AppBadge(
                                            text: test.passed ? 'PASS' : 'FAIL',
                                            variant: test.passed
                                                ? BadgeVariant.success
                                                : BadgeVariant.danger,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: AppStyles.space2),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            controller: controllers[entry.key],
                                            decoration: InputDecoration(
                                              labelText: 'Measured Value',
                                              suffixText: test.unit,
                                              border:
                                                  const OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setDialogState(() {});
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: AppStyles.space2),
                                        Expanded(
                                          child: Text(
                                            'Standard:\n${test.rangeText}',
                                            style: AppStyles.bodyXs.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: AppStyles.space4),

                          // Defects
                          Row(
                            children: [
                              Text('Defects Found', style: AppStyles.labelMd),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  setDialogState(() {
                                    defects.add(
                                      Defect(
                                        defectType: 'General',
                                        severity: 'minor',
                                        description: '',
                                        status: 'open',
                                        reportedAt: DateTime.now(),
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Defect'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppStyles.space2),

                          if (defects.isEmpty)
                            Text(
                              'No defects recorded',
                              style: AppStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            )
                          else
                            ...defects.asMap().entries.map((entry) {
                              final index = entry.key;
                              final defect = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppStyles.space2,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppStyles.space2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppStyles.radiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.bug_report,
                                        size: 16,
                                        color: AppColors.error,
                                      ),
                                      const SizedBox(width: AppStyles.space2),
                                      Expanded(
                                        child: Text(
                                          defect.defectType,
                                          style: AppStyles.bodyXs,
                                        ),
                                      ),
                                      AppBadge(
                                        text: defect.severity.toUpperCase(),
                                        variant: defect.severity == 'critical'
                                            ? BadgeVariant.danger
                                            : BadgeVariant.warning,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16),
                                        onPressed: () {
                                          setDialogState(() {
                                            defects.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                          const SizedBox(height: AppStyles.space4),

                          // Remarks
                          AppTextField(
                            controller: remarksController,
                            label: 'Remarks',
                            hint: 'Enter any additional notes',
                            maxLines: 3,
                          ),

                          const SizedBox(height: AppStyles.space4),

                          // Summary
                          Container(
                            padding: const EdgeInsets.all(AppStyles.space3),
                            decoration: BoxDecoration(
                              color: allTestsPassed
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusMd,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  allTestsPassed
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: allTestsPassed
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: AppStyles.space2),
                                Expanded(
                                  child: Text(
                                    allTestsPassed
                                        ? 'All tests passed - Ready for approval'
                                        : 'Some tests failed or not completed',
                                    style: AppStyles.labelMd.copyWith(
                                      color: allTestsPassed
                                          ? AppColors.success
                                          : AppColors.warning,
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
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Reject',
                            onPressed: () async {
                              await _saveInspection(
                                batch,
                                tests,
                                defects,
                                remarksController.text,
                                'rejected',
                                user.userId,
                                user.name,
                              );
                              Navigator.pop(context);
                            },
                            variant: ButtonVariant.outline,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                        Expanded(
                          child: AppButton(
                            text: 'Save',
                            onPressed: () async {
                              await _saveInspection(
                                batch,
                                tests,
                                defects,
                                remarksController.text,
                                'pending',
                                user.userId,
                                user.name,
                              );
                              Navigator.pop(context);
                            },
                            variant: ButtonVariant.outline,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'Approve',
                            icon: Icons.check,
                            onPressed: allTestsPassed
                                ? () async {
                                    await _saveInspection(
                                      batch,
                                      tests,
                                      defects,
                                      remarksController.text,
                                      'approved',
                                      user.userId,
                                      user.name,
                                    );
                                    Navigator.pop(context);
                                  }
                                : null,
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

    // Dispose controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    remarksController.dispose();
  }

  Future<void> _saveInspection(
    Production batch,
    Map<String, TestResult> tests,
    List<Defect> defects,
    String remarks,
    String status,
    int userId,
    String userName,
  ) async {
    final inspection = QualityInspection(
      batchId: batch.productionId,
      batchNumber: 'BATCH-${batch.productionId}',
      productName: batch.productName ?? 'Unknown',
      inspectorId: userId,
      inspectorName: userName,
      inspectionDate: DateTime.now(),
      tests: tests,
      status: status,
      remarks: remarks.isNotEmpty ? remarks : null,
      defects: defects,
      createdAt: DateTime.now(),
    );

    try {
      final existingInspection = _getInspectionForBatch(batch.productionId);

      if (existingInspection != null) {
        await QualityInspectionService.updateInspection(
          QualityInspection(
            inspectionId: existingInspection.inspectionId,
            batchId: batch.productionId,
            batchNumber: 'BATCH-${batch.productionId}',
            productName: batch.productName ?? 'Unknown',
            inspectorId: userId,
            inspectorName: userName,
            inspectionDate: existingInspection.inspectionDate,
            tests: tests,
            status: status,
            remarks: remarks.isNotEmpty ? remarks : null,
            defects: defects,
            createdAt: existingInspection.createdAt,
          ),
        );
      } else {
        await QualityInspectionService.createInspection(inspection);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inspection $status successfully'),
            backgroundColor: status == 'approved'
                ? AppColors.success
                : status == 'rejected'
                ? AppColors.error
                : AppColors.info,
          ),
        );
      }

      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving inspection: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              _buildFilterChip('all', 'All Batches', _batches.length),
              const SizedBox(width: AppStyles.space2),
              _buildFilterChip(
                'pending',
                'Pending',
                _batches.length - _inspections.length,
              ),
              const SizedBox(width: AppStyles.space2),
              _buildFilterChip('inspected', 'Inspected', _inspections.length),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredBatches.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    icon: Icons.science,
                    title: 'No Batches Found',
                    subtitle: 'No production batches available for inspection',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppStyles.space4),
                    itemCount: _filteredBatches.length,
                    itemBuilder: (context, index) {
                      final batch = _filteredBatches[index];
                      final inspection = _getInspectionForBatch(
                        batch.productionId,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppStyles.space3,
                        ),
                        child: _buildBatchCard(batch, inspection),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildBatchCard(Production batch, QualityInspection? inspection) {
    final hasInspection = inspection != null;
    final color = hasInspection
        ? (inspection.isApproved
              ? AppColors.success
              : inspection.isRejected
              ? AppColors.error
              : AppColors.warning)
        : AppColors.gray400;

    return AppCard(
      border: hasInspection ? Border.all(color: color, width: 2) : null,
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
                child: Icon(
                  hasInspection
                      ? (inspection.isApproved
                            ? Icons.check_circle
                            : inspection.isRejected
                            ? Icons.cancel
                            : Icons.pending)
                      : Icons.science,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.productName ?? 'Unknown Product',
                      style: AppStyles.labelLg,
                    ),
                    Text(
                      'Batch #${batch.productionId} • ${batch.outputQty} kg',
                      style: AppStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasInspection)
                AppBadge(
                  text: inspection.status.toUpperCase(),
                  variant: inspection.isApproved
                      ? BadgeVariant.success
                      : inspection.isRejected
                      ? BadgeVariant.danger
                      : BadgeVariant.warning,
                ),
            ],
          ),
          const SizedBox(height: AppStyles.space3),

          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(DateTime.parse(batch.date)),
                style: AppStyles.bodyXs,
              ),
              const SizedBox(width: AppStyles.space3),
              Icon(Icons.person, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(batch.supervisorName ?? 'Unknown', style: AppStyles.bodyXs),
            ],
          ),

          if (hasInspection) ...[
            const SizedBox(height: AppStyles.space3),
            Container(
              padding: const EdgeInsets.all(AppStyles.space2),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppStyles.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Inspected by: ${inspection.inspectorName}',
                    style: AppStyles.bodyXs,
                  ),
                  const Spacer(),
                  Text(
                    DateFormat(
                      'MMM dd, HH:mm',
                    ).format(inspection.inspectionDate),
                    style: AppStyles.bodyXs.copyWith(
                      color: AppColors.textSecondary,
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
                onPressed: () => _showInspectionDialog(batch),
                icon: Icon(
                  hasInspection ? Icons.edit : Icons.science,
                  size: 18,
                ),
                label: Text(hasInspection ? 'View/Edit' : 'Inspect'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
