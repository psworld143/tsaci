import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'app_button.dart';

/// Advanced Search and Filter Widget
class AdvancedSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;
  final List<FilterField> filterFields;
  final String? initialSearchTerm;

  const AdvancedSearchWidget({
    Key? key,
    required this.onSearch,
    required this.filterFields,
    this.initialSearchTerm,
  }) : super(key: key);

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, dynamic> _filters = {};
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchTerm != null) {
      _searchController.text = widget.initialSearchTerm!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = {'search': _searchController.text, ..._filters};
    widget.onSearch(filters);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filters.clear();
    });
    widget.onSearch({});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _searchController.clear());
                            _applyFilters();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radiusLg),
                  ),
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
                onSubmitted: (_) => _applyFilters(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppStyles.space2),
            IconButton(
              icon: Icon(
                _showAdvancedFilters
                    ? Icons.filter_list_off
                    : Icons.filter_list,
                color: _showAdvancedFilters ? AppColors.primary : null,
              ),
              onPressed: () {
                setState(() => _showAdvancedFilters = !_showAdvancedFilters);
              },
              tooltip: 'Advanced Filters',
            ),
            AppButton(
              text: 'Search',
              onPressed: _applyFilters,
              icon: Icons.search,
              size: ButtonSize.md,
            ),
          ],
        ),

        // Advanced Filters Panel
        if (_showAdvancedFilters) ...[
          const SizedBox(height: AppStyles.space4),
          Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(AppStyles.radiusLg),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_alt, color: AppColors.primary),
                    const SizedBox(width: AppStyles.space2),
                    Text('Advanced Filters', style: AppStyles.labelLg),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.space4),
                Wrap(
                  spacing: AppStyles.space3,
                  runSpacing: AppStyles.space3,
                  children: widget.filterFields
                      .map((field) => _buildFilterField(field))
                      .toList(),
                ),
                const SizedBox(height: AppStyles.space4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'Apply Filters',
                      onPressed: _applyFilters,
                      icon: Icons.check,
                      size: ButtonSize.md,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterField(FilterField field) {
    switch (field.type) {
      case FilterType.dropdown:
        return SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            value: _filters[field.key],
            items: field.options
                ?.map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  _filters[field.key] = value;
                } else {
                  _filters.remove(field.key);
                }
              });
            },
          ),
        );

      case FilterType.dateRange:
        return SizedBox(
          width: 300,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, field.key, true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start ${field.label}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    child: Text(
                      _filters['${field.key}_start'] != null
                          ? DateFormat(
                              'yyyy-MM-dd',
                            ).format(_filters['${field.key}_start'])
                          : 'Select date',
                      style: AppStyles.bodySm,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, field.key, false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End ${field.label}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    child: Text(
                      _filters['${field.key}_end'] != null
                          ? DateFormat(
                              'yyyy-MM-dd',
                            ).format(_filters['${field.key}_end'])
                          : 'Select date',
                      style: AppStyles.bodySm,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case FilterType.numberRange:
        return SizedBox(
          width: 300,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Min ${field.label}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        _filters['${field.key}_min'] = double.tryParse(value);
                      } else {
                        _filters.remove('${field.key}_min');
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: AppStyles.space2),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Max ${field.label}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        _filters['${field.key}_max'] = double.tryParse(value);
                      } else {
                        _filters.remove('${field.key}_max');
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        );

      case FilterType.checkbox:
        return SizedBox(
          width: 200,
          child: CheckboxListTile(
            title: Text(field.label, style: AppStyles.bodyMd),
            value: _filters[field.key] ?? false,
            onChanged: (value) {
              setState(() => _filters[field.key] = value ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
        );
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    String key,
    bool isStart,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _filters['${key}_${isStart ? 'start' : 'end'}'] = picked;
      });
    }
  }
}

/// Filter Field Definition
class FilterField {
  final String key;
  final String label;
  final FilterType type;
  final List<String>? options;

  FilterField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
  });
}

/// Filter Types
enum FilterType { dropdown, dateRange, numberRange, checkbox }
