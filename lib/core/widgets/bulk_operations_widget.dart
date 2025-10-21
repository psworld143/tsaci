import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'app_button.dart';

/// Bulk Operations Widget for managing multiple items at once
class BulkOperationsWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdateStatus;
  final VoidCallback? onExport;
  final List<Widget>? customActions;

  const BulkOperationsWidget({
    Key? key,
    required this.selectedCount,
    this.onSelectAll,
    this.onDeselectAll,
    this.onDelete,
    this.onUpdateStatus,
    this.onExport,
    this.customActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusLg),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Selection count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.space3,
              vertical: AppStyles.space2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
            ),
            child: Text(
              '$selectedCount selected',
              style: AppStyles.labelMd.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppStyles.space3),

          // Select/Deselect All
          if (onSelectAll != null && onDeselectAll != null) ...[
            TextButton.icon(
              onPressed: onDeselectAll,
              icon: const Icon(Icons.deselect, size: 18),
              label: const Text('Deselect All'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            const SizedBox(width: AppStyles.space2),
          ],

          const Spacer(),

          // Actions
          Wrap(
            spacing: AppStyles.space2,
            children: [
              // Export
              if (onExport != null)
                AppButton(
                  text: 'Export',
                  onPressed: onExport,
                  icon: Icons.download,
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                ),

              // Update Status
              if (onUpdateStatus != null)
                AppButton(
                  text: 'Update Status',
                  onPressed: onUpdateStatus,
                  icon: Icons.edit,
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                ),

              // Custom Actions
              if (customActions != null) ...customActions!,

              // Delete
              if (onDelete != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.error),
                    borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                  ),
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete Selected'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.space3,
                        vertical: AppStyles.space2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Selectable List Tile for bulk operations
class SelectableListTile extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final Widget child;
  final Color? selectedColor;

  const SelectableListTile({
    Key? key,
    required this.isSelected,
    required this.onChanged,
    required this.child,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? (selectedColor ?? AppColors.primary).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
        border: isSelected
            ? Border.all(
                color: (selectedColor ?? AppColors.primary).withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: onChanged,
            activeColor: selectedColor ?? AppColors.primary,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Bulk Actions Dialog
class BulkActionsDialog {
  /// Show delete confirmation dialog
  static Future<bool?> showDeleteConfirmation(
    BuildContext context, {
    required int count,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: AppStyles.space3),
            Text('Confirm Deletion'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete $count selected item${count > 1 ? 's' : ''}?\n\n'
          'This action cannot be undone.',
          style: AppStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete $count Item${count > 1 ? 's' : ''}'),
          ),
        ],
      ),
    );
  }

  /// Show status update dialog
  static Future<String?> showStatusUpdateDialog(
    BuildContext context, {
    required List<String> statusOptions,
    String? currentStatus,
  }) {
    String? selectedStatus = currentStatus;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select new status for selected items:',
                style: AppStyles.bodyMd,
              ),
              const SizedBox(height: AppStyles.space4),
              ...statusOptions.map(
                (status) => RadioListTile<String>(
                  title: Text(status),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setState(() => selectedStatus = value);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStatus != null
                  ? () => Navigator.pop(context, selectedStatus)
                  : null,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show export options dialog
  static Future<String?> showExportDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_download, color: AppColors.primary),
            SizedBox(width: AppStyles.space3),
            Text('Export Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('Export as CSV'),
              subtitle: const Text('Excel-compatible format'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('Export as PDF'),
              subtitle: const Text('Printable document'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
          ],
        ),
      ),
    );
  }
}
