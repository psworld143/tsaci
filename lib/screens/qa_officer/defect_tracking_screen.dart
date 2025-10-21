import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/quality_inspection_model.dart';
import '../../services/quality_inspection_service.dart';
import '../../utils/export_helper.dart';

class DefectTrackingScreen extends StatefulWidget {
  const DefectTrackingScreen({Key? key}) : super(key: key);

  @override
  State<DefectTrackingScreen> createState() => _DefectTrackingScreenState();
}

class _DefectTrackingScreenState extends State<DefectTrackingScreen> {
  List<QualityInspection> _inspections = [];
  bool _isLoading = true;
  String _filterSeverity = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final inspections = await QualityInspectionService.getAllInspections();

      if (mounted) {
        setState(() {
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

  List<Defect> get _allDefects {
    final defects = <Defect>[];
    for (var inspection in _inspections) {
      defects.addAll(inspection.defects);
    }
    return defects;
  }

  List<Defect> get _filteredDefects {
    var defects = _allDefects;

    // Filter by severity
    if (_filterSeverity != 'all') {
      defects = defects.where((d) => d.severity == _filterSeverity).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      defects = defects.where((d) {
        return d.defectType.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            d.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by date (newest first)
    defects.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

    return defects;
  }

  Future<void> _handleExport() async {
    try {
      final data = _filteredDefects
          .map(
            (defect) => {
              'Date': DateFormat('yyyy-MM-dd HH:mm').format(defect.reportedAt),
              'Type': defect.defectType,
              'Severity': defect.severity.toUpperCase(),
              'Description': defect.description,
              'Status': defect.status.toUpperCase(),
              'Corrective Action': defect.correctiveAction ?? 'N/A',
            },
          )
          .toList();

      await ExportHelper.exportToCSV(data: data, filename: 'defect_tracking');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Defects exported successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final critical = _allDefects.where((d) => d.severity == 'critical').length;
    final major = _allDefects.where((d) => d.severity == 'major').length;
    final minor = _allDefects.where((d) => d.severity == 'minor').length;
    final open = _allDefects.where((d) => d.isOpen).length;

    return Column(
      children: [
        // Summary Bar
        Container(
          padding: const EdgeInsets.all(AppStyles.space4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryStat(
                      'Total',
                      _allDefects.length,
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryStat(
                      'Critical',
                      critical,
                      AppColors.error,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryStat('Major', major, AppColors.warning),
                  ),
                  Expanded(
                    child: _buildSummaryStat('Minor', minor, AppColors.info),
                  ),
                  Expanded(
                    child: _buildSummaryStat('Open', open, AppColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.space3),

              // Search and Export
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search defects...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusLg,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.gray50,
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: AppStyles.space2),
                  if (_filteredDefects.isNotEmpty)
                    AppButton(
                      text: 'Export',
                      icon: Icons.download,
                      onPressed: _handleExport,
                      variant: ButtonVariant.outline,
                      size: ButtonSize.sm,
                    ),
                ],
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
                _buildFilterChip('all', 'All', _allDefects.length),
                const SizedBox(width: AppStyles.space2),
                _buildFilterChip('critical', 'Critical', critical),
                const SizedBox(width: AppStyles.space2),
                _buildFilterChip('major', 'Major', major),
                const SizedBox(width: AppStyles.space2),
                _buildFilterChip('minor', 'Minor', minor),
                const SizedBox(width: AppStyles.space2),
                _buildFilterChip(
                  'cosmetic',
                  'Cosmetic',
                  _allDefects.where((d) => d.severity == 'cosmetic').length,
                ),
              ],
            ),
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDefects.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    icon: Icons.bug_report,
                    title: 'No Defects Found',
                    subtitle: 'No defects match your filters',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppStyles.space4),
                    itemCount: _filteredDefects.length,
                    itemBuilder: (context, index) {
                      final defect = _filteredDefects[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppStyles.space3,
                        ),
                        child: _buildDefectCard(defect),
                      );
                    },
                  ),
                ),
        ),
      ],
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

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filterSeverity == value;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterSeverity = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildDefectCard(Defect defect) {
    final color = _getSeverityColor(defect.severity);

    return AppCard(
      border: defect.isCritical ? Border.all(color: color, width: 2) : null,
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
                  _getSeverityIcon(defect.severity),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppStyles.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(defect.defectType, style: AppStyles.labelLg),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy HH:mm',
                      ).format(defect.reportedAt),
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
                  AppBadge(
                    text: defect.severity.toUpperCase(),
                    variant: _getSeverityBadgeVariant(defect.severity),
                  ),
                  const SizedBox(height: 4),
                  AppBadge(
                    text: defect.status.toUpperCase(),
                    variant: defect.isOpen
                        ? BadgeVariant.warning
                        : BadgeVariant.success,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space3),

          // Description
          Container(
            padding: const EdgeInsets.all(AppStyles.space2),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(AppStyles.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.description,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppStyles.space2),
                Expanded(
                  child: Text(
                    defect.description.isNotEmpty
                        ? defect.description
                        : 'No description provided',
                    style: AppStyles.bodyXs,
                  ),
                ),
              ],
            ),
          ),

          // Corrective Action
          if (defect.correctiveAction != null) ...[
            const SizedBox(height: AppStyles.space2),
            Container(
              padding: const EdgeInsets.all(AppStyles.space2),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.build, size: 14, color: AppColors.success),
                  const SizedBox(width: AppStyles.space2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Corrective Action:',
                          style: AppStyles.labelSm.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text(defect.correctiveAction!, style: AppStyles.bodyXs),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'major':
        return AppColors.warning;
      case 'minor':
        return AppColors.info;
      case 'cosmetic':
        return AppColors.gray500;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'major':
        return Icons.warning;
      case 'minor':
        return Icons.info;
      case 'cosmetic':
        return Icons.palette;
      default:
        return Icons.bug_report;
    }
  }

  BadgeVariant _getSeverityBadgeVariant(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return BadgeVariant.danger;
      case 'major':
        return BadgeVariant.warning;
      case 'minor':
        return BadgeVariant.info;
      case 'cosmetic':
        return BadgeVariant.gray;
      default:
        return BadgeVariant.gray;
    }
  }
}
