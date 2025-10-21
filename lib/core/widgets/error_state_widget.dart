import 'package:flutter/material.dart';
import '../../models/app_error_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'app_button.dart';

/// Inline Error State Widget
/// Perfect for showing errors in cards, sections, or list items
class ErrorStateWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool compact;

  const ErrorStateWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType();

    if (compact) {
      return _buildCompactView(color);
    }

    return _buildFullView(color);
  }

  Widget _buildFullView(Color color) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.space5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusLg),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForType(), size: 48, color: color),
          const SizedBox(height: AppStyles.space3),
          Text(
            error.title,
            style: AppStyles.labelMd.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppStyles.space2),
          Text(
            error.message,
            style: AppStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (error.isRetryable && onRetry != null) ...[
            const SizedBox(height: AppStyles.space4),
            AppButton(
              text: 'Retry',
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactView(Color color) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.space3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getIconForType(), size: 24, color: color),
          const SizedBox(width: AppStyles.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.title,
                  style: AppStyles.bodySm.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  error.message,
                  style: AppStyles.bodyXs.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (error.isRetryable && onRetry != null) ...[
            const SizedBox(width: AppStyles.space2),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: color,
              onPressed: onRetry,
              iconSize: 20,
            ),
          ],
        ],
      ),
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
}
