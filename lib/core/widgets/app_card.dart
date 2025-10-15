import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Tailwind-inspired Card Widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool elevated;
  final double? borderRadius;
  final Border? border;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.elevated = false,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppStyles.radiusLg),
        border: border ?? Border.all(color: AppColors.gray200, width: 1),
        boxShadow: elevated ? AppStyles.shadowMd : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppStyles.radiusLg,
          ),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Stat Card for Dashboard Widgets
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return AppCard(
      onTap: onTap,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.space2),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                ),
                child: Icon(icon, color: cardColor, size: 24),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppStyles.bodyXs.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppStyles.space3),
          Text(
            title,
            style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppStyles.space1),
          Text(value, style: AppStyles.headingMd.copyWith(color: cardColor)),
        ],
      ),
    );
  }
}
