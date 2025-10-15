import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Custom Button Variants (Tailwind-inspired)
enum ButtonVariant {
  primary,
  secondary,
  success,
  danger,
  warning,
  outline,
  ghost,
}

enum ButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Size configurations
    double height;
    double fontSize;
    EdgeInsets padding;

    switch (size) {
      case ButtonSize.sm:
        height = 36;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: AppStyles.space3);
        break;
      case ButtonSize.lg:
        height = 52;
        fontSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: AppStyles.space8);
        break;
      case ButtonSize.md:
      default:
        height = 44;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: AppStyles.space6);
    }

    // Color configurations
    Color bgColor;
    Color textColor;
    Color? borderColor;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.primary;
        textColor = AppColors.textLight;
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.textLight;
        break;
      case ButtonVariant.success:
        bgColor = AppColors.success;
        textColor = AppColors.textLight;
        break;
      case ButtonVariant.danger:
        bgColor = AppColors.error;
        textColor = AppColors.textLight;
        break;
      case ButtonVariant.warning:
        bgColor = AppColors.warning;
        textColor = AppColors.textPrimary;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case ButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        break;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation:
              variant == ButtonVariant.outline || variant == ButtonVariant.ghost
              ? 0
              : 2,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize),
                    const SizedBox(width: AppStyles.space2),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Icon Button with Tailwind styling
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.gray100,
        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: color ?? AppColors.textPrimary,
        iconSize: size * 0.5,
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
