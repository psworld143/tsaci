import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../models/app_error_model.dart';

/// Demo screen showcasing all error handling components
/// This is for development/testing purposes
class ErrorHandlingDemoScreen extends StatefulWidget {
  const ErrorHandlingDemoScreen({Key? key}) : super(key: key);

  @override
  State<ErrorHandlingDemoScreen> createState() =>
      _ErrorHandlingDemoScreenState();
}

class _ErrorHandlingDemoScreenState extends State<ErrorHandlingDemoScreen> {
  bool _isLoading = false;

  // Sample errors for demonstration
  final List<Map<String, dynamic>> _errorExamples = [
    {
      'name': 'Network Error (XAMPP Down)',
      'error': DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.connectionError,
        message: 'Connection refused',
      ),
    },
    {
      'name': 'Authentication Error (401)',
      'error': DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api'),
          statusCode: 401,
          data: {'message': 'Invalid credentials'},
        ),
      ),
    },
    {
      'name': 'Validation Error (422)',
      'error': DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api'),
          statusCode: 422,
          data: {'message': 'Email is required'},
        ),
      ),
    },
    {
      'name': 'Server Error (500)',
      'error': DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api'),
          statusCode: 500,
          data: {'message': 'Internal server error'},
        ),
      ),
    },
    {
      'name': 'Timeout Error',
      'error': DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      ),
    },
    {
      'name': 'Not Found (404)',
      'error': DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api'),
          statusCode: 404,
          data: {'message': 'Resource not found'},
        ),
      ),
    },
  ];

  void _showErrorDialog(dynamic error) {
    final appError = AppError.fromException(error);
    ErrorDialog.show(
      context,
      error: appError,
      onRetry: appError.isRetryable
          ? () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Retry triggered!')));
            }
          : null,
    );
  }

  void _showFullScreenError(dynamic error) {
    final appError = AppError.fromException(error);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: NetworkErrorScreen(
            error: appError,
            onRetry: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Retry triggered!')));
            },
          ),
        ),
      ),
    );
  }

  void _showLoadingDemo() {
    setState(() => _isLoading = true);
    LoadingOverlay.show(context, message: 'Loading data...');

    Future.delayed(const Duration(seconds: 2), () {
      LoadingOverlay.hide(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loading complete!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Error Handling Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.space3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.bug_report_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppStyles.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error Handling System',
                              style: AppStyles.headingSm,
                            ),
                            const SizedBox(height: AppStyles.space1),
                            Text(
                              'Test all error UI components',
                              style: AppStyles.bodySm,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppStyles.space6),

            // Error Dialog Examples
            Text('Error Dialogs', style: AppStyles.headingSm),
            const SizedBox(height: AppStyles.space3),
            Text(
              'Modal dialogs for user actions',
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.space3),
            ..._errorExamples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: AppStyles.space2),
                child: AppButton(
                  text: example['name'],
                  onPressed: () => _showErrorDialog(example['error']),
                  variant: ButtonVariant.outline,
                  fullWidth: true,
                  icon: Icons.error_outline,
                ),
              ),
            ),

            const SizedBox(height: AppStyles.space6),

            // Full Screen Error Examples
            Text('Full Screen Errors', style: AppStyles.headingSm),
            const SizedBox(height: AppStyles.space3),
            Text(
              'Complete screen takeover for major failures',
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.space3),
            AppButton(
              text: 'Show Network Error Screen',
              onPressed: () => _showFullScreenError(_errorExamples[0]['error']),
              variant: ButtonVariant.primary,
              fullWidth: true,
              icon: Icons.wifi_off_rounded,
            ),

            const SizedBox(height: AppStyles.space6),

            // Inline Error States
            Text('Inline Error States', style: AppStyles.headingSm),
            const SizedBox(height: AppStyles.space3),
            Text(
              'Errors within cards and sections',
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.space3),

            // Full inline error
            ErrorStateWidget(
              error: AppError.fromException(_errorExamples[0]['error']),
              onRetry: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Retry triggered!')),
                );
              },
            ),

            const SizedBox(height: AppStyles.space3),

            // Compact inline error
            ErrorStateWidget(
              error: AppError.fromException(_errorExamples[1]['error']),
              onRetry: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Retry triggered!')),
                );
              },
              compact: true,
            ),

            const SizedBox(height: AppStyles.space6),

            // Loading Overlay
            Text('Loading States', style: AppStyles.headingSm),
            const SizedBox(height: AppStyles.space3),
            Text(
              'Beautiful loading indicators',
              style: AppStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.space3),
            AppButton(
              text: 'Show Loading Overlay',
              onPressed: _showLoadingDemo,
              variant: ButtonVariant.primary,
              fullWidth: true,
              icon: Icons.hourglass_empty_rounded,
              loading: _isLoading,
            ),

            const SizedBox(height: AppStyles.space6),

            // Info Card
            Container(
              padding: const EdgeInsets.all(AppStyles.space4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusLg),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.info),
                  const SizedBox(width: AppStyles.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn More',
                          style: AppStyles.labelMd.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space1),
                        Text(
                          'Check ERROR_HANDLING_GUIDE.md for complete documentation and usage examples.',
                          style: AppStyles.bodySm.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppStyles.space6),
          ],
        ),
      ),
    );
  }
}
