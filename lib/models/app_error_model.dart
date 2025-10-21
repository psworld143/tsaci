import 'package:dio/dio.dart';

/// Error Types
enum ErrorType {
  network,
  server,
  authentication,
  validation,
  timeout,
  notFound,
  unknown,
}

/// App Error Model
class AppError {
  final ErrorType type;
  final String title;
  final String message;
  final String? technicalDetails;
  final int? statusCode;
  final bool isRetryable;
  final String? action;

  AppError({
    required this.type,
    required this.title,
    required this.message,
    this.technicalDetails,
    this.statusCode,
    this.isRetryable = false,
    this.action,
  });

  /// Parse error from exception
  factory AppError.fromException(dynamic error) {
    if (error is DioException) {
      return AppError._fromDioException(error);
    }

    if (error is Exception) {
      final errorMessage = error.toString().replaceAll('Exception: ', '');

      // Check if it's a network error
      if (errorMessage.contains('Network error') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('SocketException')) {
        return AppError._networkError(errorMessage);
      }

      // Check if it's an authentication error
      if (errorMessage.contains('Invalid credentials') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('authentication')) {
        return AppError._authenticationError(errorMessage);
      }

      // Generic error
      return AppError(
        type: ErrorType.unknown,
        title: 'Something went wrong',
        message: errorMessage,
        isRetryable: true,
      );
    }

    // Unknown error type
    return AppError(
      type: ErrorType.unknown,
      title: 'Unexpected Error',
      message: error?.toString() ?? 'An unexpected error occurred',
      isRetryable: true,
    );
  }

  /// Network error
  factory AppError._networkError(String? details) {
    return AppError(
      type: ErrorType.network,
      title: 'Connection Failed',
      message:
          'Unable to connect to the server. Please check your network connection and ensure the backend server is running.',
      technicalDetails: details,
      isRetryable: true,
      action: 'Start XAMPP and try again',
    );
  }

  /// Authentication error
  factory AppError._authenticationError(String message) {
    return AppError(
      type: ErrorType.authentication,
      title: 'Authentication Failed',
      message: message,
      isRetryable: false,
      action: 'Check your credentials',
    );
  }

  /// Parse Dio exception
  factory AppError._fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          type: ErrorType.timeout,
          title: 'Request Timeout',
          message: 'The request took too long to complete. Please try again.',
          technicalDetails: error.message,
          isRetryable: true,
          action: 'Check your internet connection',
        );

      case DioExceptionType.connectionError:
        return AppError(
          type: ErrorType.network,
          title: 'Connection Failed',
          message:
              'Unable to connect to the server. Please ensure:\n\n'
              '✓ Your internet connection is active\n'
              '✓ XAMPP/Apache server is running\n'
              '✓ Backend is accessible',
          technicalDetails: error.message,
          isRetryable: true,
          action: 'Start XAMPP and try again',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 401:
            return AppError(
              type: ErrorType.authentication,
              title: 'Authentication Failed',
              message:
                  data?['message'] ??
                  'Invalid credentials. Please check your email and password.',
              statusCode: statusCode,
              technicalDetails: error.message,
              isRetryable: false,
            );

          case 404:
            return AppError(
              type: ErrorType.notFound,
              title: 'Not Found',
              message:
                  data?['message'] ?? 'The requested resource was not found.',
              statusCode: statusCode,
              technicalDetails: error.message,
              isRetryable: false,
            );

          case 422:
            return AppError(
              type: ErrorType.validation,
              title: 'Validation Error',
              message:
                  data?['message'] ?? 'Please check your input and try again.',
              statusCode: statusCode,
              technicalDetails: error.message,
              isRetryable: false,
            );

          case 500:
          case 502:
          case 503:
            return AppError(
              type: ErrorType.server,
              title: 'Server Error',
              message:
                  'The server encountered an error. Please try again later.',
              statusCode: statusCode,
              technicalDetails: error.message,
              isRetryable: true,
            );

          default:
            return AppError(
              type: ErrorType.server,
              title: 'Server Error',
              message:
                  data?['message'] ?? 'Something went wrong on the server.',
              statusCode: statusCode,
              technicalDetails: error.message,
              isRetryable: true,
            );
        }

      case DioExceptionType.cancel:
        return AppError(
          type: ErrorType.unknown,
          title: 'Request Cancelled',
          message: 'The request was cancelled.',
          technicalDetails: error.message,
          isRetryable: true,
        );

      default:
        return AppError(
          type: ErrorType.unknown,
          title: 'Network Error',
          message: 'An unexpected network error occurred.',
          technicalDetails: error.message,
          isRetryable: true,
        );
    }
  }

  /// Get icon for error type
  String get icon {
    switch (type) {
      case ErrorType.network:
        return '📡';
      case ErrorType.server:
        return '🖥️';
      case ErrorType.authentication:
        return '🔐';
      case ErrorType.validation:
        return '⚠️';
      case ErrorType.timeout:
        return '⏱️';
      case ErrorType.notFound:
        return '🔍';
      case ErrorType.unknown:
        return '❌';
    }
  }
}
