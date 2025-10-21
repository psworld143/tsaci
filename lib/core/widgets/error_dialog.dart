import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/app_error_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'app_button.dart';

/// Beautiful Error Dialog
class ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  /// Show error dialog
  static Future<void> show(
    BuildContext context, {
    required AppError error,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ErrorDialog(error: error, onRetry: onRetry, onDismiss: onDismiss),
    );
  }

  Color _getColorForType() {
    switch (error.type) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.authentication:
        return AppColors.error;
      case ErrorType.validation:
        return AppColors.warning;
      case ErrorType.timeout:
        return AppColors.warning;
      case ErrorType.server:
        return AppColors.error;
      case ErrorType.notFound:
        return AppColors.info;
      default:
        return AppColors.error;
    }
  }

  IconData _getIconForType() {
    switch (error.type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.authentication:
        return Icons.lock_outline_rounded;
      case ErrorType.validation:
        return Icons.warning_amber_rounded;
      case ErrorType.timeout:
        return Icons.access_time_rounded;
      case ErrorType.server:
        return Icons.storage_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType();
    final icon = _getIconForType();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusLg),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              padding: const EdgeInsets.all(AppStyles.space6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.radiusLg),
                  topRight: Radius.circular(AppStyles.radiusLg),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.space4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 48, color: color),
                  ),
                  const SizedBox(height: AppStyles.space4),
                  Text(
                    error.title,
                    style: AppStyles.headingSm.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppStyles.space6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Message
                  Text(
                    error.message,
                    style: AppStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Action hint
                  if (error.action != null) ...[
                    const SizedBox(height: AppStyles.space4),
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space3),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 20,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: AppStyles.space2),
                          Expanded(
                            child: Text(
                              error.action!,
                              style: AppStyles.bodySm.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Technical details (expandable)
                  if (error.technicalDetails != null) ...[
                    const SizedBox(height: AppStyles.space4),
                    ExpansionTile(
                      title: Text(
                        'Technical Details',
                        style: AppStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(
                        bottom: AppStyles.space3,
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppStyles.space3),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(
                              AppStyles.radiusSm,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  error.technicalDetails!,
                                  style: AppStyles.bodyXs.copyWith(
                                    fontFamily: 'monospace',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: error.technicalDetails!,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppStyles.space6),

                  // Buttons
                  Row(
                    children: [
                      if (error.isRetryable && onRetry != null) ...[
                        Expanded(
                          child: AppButton(
                            text: 'Retry',
                            onPressed: () {
                              Navigator.of(context).pop();
                              onRetry?.call();
                            },
                            icon: Icons.refresh_rounded,
                            variant: ButtonVariant.primary,
                          ),
                        ),
                        const SizedBox(width: AppStyles.space3),
                      ],
                      Expanded(
                        child: AppButton(
                          text: error.isRetryable && onRetry != null
                              ? 'Close'
                              : 'OK',
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDismiss?.call();
                          },
                          variant: error.isRetryable && onRetry != null
                              ? ButtonVariant.outline
                              : ButtonVariant.primary,
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
    );
  }
}
