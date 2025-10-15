import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Badge/Chip Widget (Tailwind-inspired)
enum BadgeVariant { primary, success, warning, danger, info, gray }

class AppBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    Key? key,
    required this.text,
    this.variant = BadgeVariant.primary,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (variant) {
      case BadgeVariant.primary:
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;
      case BadgeVariant.success:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case BadgeVariant.warning:
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case BadgeVariant.danger:
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case BadgeVariant.info:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case BadgeVariant.gray:
        bgColor = AppColors.gray200;
        textColor = AppColors.gray700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.space2,
        vertical: AppStyles.space1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(text, style: AppStyles.labelSm.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

/// Status Badge
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BadgeVariant variant;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'active':
        variant = BadgeVariant.success;
        icon = Icons.check_circle;
        break;
      case 'pending':
      case 'processing':
        variant = BadgeVariant.warning;
        icon = Icons.pending;
        break;
      case 'cancelled':
      case 'failed':
      case 'error':
        variant = BadgeVariant.danger;
        icon = Icons.cancel;
        break;
      case 'info':
        variant = BadgeVariant.info;
        icon = Icons.info;
        break;
      default:
        variant = BadgeVariant.gray;
        icon = null;
    }

    return AppBadge(text: status, variant: variant, icon: icon);
  }
}
