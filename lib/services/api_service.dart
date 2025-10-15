import 'package:dio/dio.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

/// API Service for HTTP requests using Dio
class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
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
      throw Exception('Network error: $e');
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
      throw Exception('Network error: $e');
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
      throw Exception('Network error: $e');
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
      throw Exception('Network error: $e');
    }
  }

  /// Handle API response
  static Map<String, dynamic> _handleResponse(Response response, String url) {
    final data = response.data;

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // Log successful response
      AppLogger.apiResponse(url, response.statusCode!, data);
      return data is Map<String, dynamic> ? data : {};
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
