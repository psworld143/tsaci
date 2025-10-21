import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/app_error_model.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

/// API Service for HTTP requests using Dio
class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  /// Get headers with authentication
  static Future<Map<String, dynamic>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request
  static Future<Map<String, dynamic>> get(String url) async {
    AppLogger.apiRequest('GET', url);

    try {
      final headers = await _getHeaders();
      final response = await _dio.get(url, options: Options(headers: headers));
      return _handleResponse(response, url);
    } catch (e) {
      AppLogger.apiError(url, 'Network error: $e');
      final appError = AppError.fromException(e);
      throw Exception(appError.message);
    }
  }

  /// POST request
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    AppLogger.apiRequest('POST', url, body);

    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );
      return _handleResponse(response, url);
    } catch (e) {
      AppLogger.apiError(url, 'Network error: $e');
      final appError = AppError.fromException(e);
      throw Exception(appError.message);
    }
  }

  /// PUT request
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    AppLogger.apiRequest('PUT', url, body);

    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        url,
        data: body,
        options: Options(headers: headers),
      );
      return _handleResponse(response, url);
    } catch (e) {
      AppLogger.apiError(url, 'Network error: $e');
      final appError = AppError.fromException(e);
      throw Exception(appError.message);
    }
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete(String url) async {
    AppLogger.apiRequest('DELETE', url);

    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        url,
        options: Options(headers: headers),
      );
      return _handleResponse(response, url);
    } catch (e) {
      AppLogger.apiError(url, 'Network error: $e');
      final appError = AppError.fromException(e);
      throw Exception(appError.message);
    }
  }

  /// Handle API response
  static Map<String, dynamic> _handleResponse(Response response, String url) {
    final data = response.data;
    
    print('[ApiService] Response status: ${response.statusCode}');
    print('[ApiService] Response data type: ${data.runtimeType}');
    print('[ApiService] Response data: $data');

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // Log successful response
      AppLogger.apiResponse(url, response.statusCode!, data);
      
      // Handle different response data types
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        try {
          final parsed = jsonDecode(data);
          return parsed is Map<String, dynamic> ? parsed : {};
        } catch (e) {
          print('[ApiService] Failed to parse JSON: $e');
          return {};
        }
      } else {
        print('[ApiService] Unexpected response type: ${data.runtimeType}');
        return {};
      }
    } else {
      // Log error response
      AppLogger.apiError(url, data['message'] ?? 'Request failed', {
        'status_code': response.statusCode,
        'response': data,
      });
      throw Exception(data['message'] ?? 'Request failed');
    }
  }
}
