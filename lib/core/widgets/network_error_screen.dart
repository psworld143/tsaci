import 'package:flutter/material.dart';
import '../../models/app_error_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'app_button.dart';

/// Beautiful Network Error Screen
class NetworkErrorScreen extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorScreen({
    Key? key,
    required this.error,
    this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType();
    final illustration = _getIllustrationForType();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated illustration
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(illustration, size: 100, color: color),
                ),
              ),
            ),
            const SizedBox(height: AppStyles.space6),

            // Title
            Text(
              error.title,
              style: AppStyles.headingMd.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.space3),

            // Message
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                customMessage ?? error.message,
                style: AppStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Action hint
            if (error.action != null) ...[
              const SizedBox(height: AppStyles.space4),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(AppStyles.space4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyles.radiusLg),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: AppStyles.space3),
                    Expanded(
                      child: Text(
                        error.action!,
                        style: AppStyles.bodyMd.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Retry button
            if (error.isRetryable && onRetry != null) ...[
              const SizedBox(height: AppStyles.space6),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: AppButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                  icon: Icons.refresh_rounded,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.lg,
                  fullWidth: true,
                ),
              ),
            ],

            // Troubleshooting tips
            if (error.type == ErrorType.network) ...[
              const SizedBox(height: AppStyles.space6),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
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
                        Icon(
                          Icons.help_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppStyles.space2),
                        Text(
                          'Troubleshooting Tips',
                          style: AppStyles.labelMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.space3),
                    _buildTroubleshootingItem(
                      '1. Ensure XAMPP/Apache is running',
                      Icons.power_rounded,
                    ),
                    _buildTroubleshootingItem(
                      '2. Check if backend is accessible',
                      Icons.link_rounded,
                    ),
                    _buildTroubleshootingItem(
                      '3. Verify your internet connection',
                      Icons.wifi_rounded,
                    ),
                    _buildTroubleshootingItem(
                      '4. Check firewall settings',
                      Icons.security_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: AppStyles.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppStyles.space2),
          Expanded(
            child: Text(
              text,
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
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
      case ErrorType.timeout:
        return AppColors.warning;
      case ErrorType.server:
        return AppColors.error;
      default:
        return AppColors.error;
    }
  }

  IconData _getIllustrationForType() {
    switch (error.type) {
      case ErrorType.network:
        return Icons.cloud_off_rounded;
      case ErrorType.authentication:
        return Icons.lock_outline_rounded;
      case ErrorType.timeout:
        return Icons.hourglass_empty_rounded;
      case ErrorType.server:
        return Icons.dns_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }
}
