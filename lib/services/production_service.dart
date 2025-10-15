import '../core/constants/api_constants.dart';
import '../models/production_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

/// Production Service
class ProductionService {
  /// Get all production logs
  static Future<List<Production>> getAll({int limit = 100}) async {
    try {
      final url = '${ApiConstants.production}?limit=$limit';
      final response = await ApiService.get(url);

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        AppLogger.success('Production logs loaded', '${data.length} items');
        return data.map((json) => Production.fromJson(json)).toList();
      } else {
        AppLogger.error('Failed to load production data', response['message']);
        throw Exception(
          response['message'] ?? 'Failed to load production data',
        );
      }
    } catch (e) {
      AppLogger.error('Production service error', e);
      rethrow;
    }
  }

  /// Get production by date range
  static Future<List<Production>> getByDateRange(
    String startDate,
    String endDate,
  ) async {
    try {
      final url =
          '${ApiConstants.productionFilterDate}?start_date=$startDate&end_date=$endDate';
      final response = await ApiService.get(url);

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        AppLogger.info(
          'Production filtered by date',
          '$startDate to $endDate: ${data.length} items',
        );
        return data.map((json) => Production.fromJson(json)).toList();
      } else {
        AppLogger.error(
          'Failed to filter production by date',
          response['message'],
        );
        throw Exception(
          response['message'] ?? 'Failed to load production data',
        );
      }
    } catch (e) {
      AppLogger.error('Production date filter error', e);
      rethrow;
    }
  }

  /// Get production by product
  static Future<List<Production>> getByProduct(int productId) async {
    try {
      final url =
          '${ApiConstants.productionFilterProduct}?product_id=$productId';
      final response = await ApiService.get(url);

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        AppLogger.info(
          'Production filtered by product',
          'Product ID $productId: ${data.length} items',
        );
        return data.map((json) => Production.fromJson(json)).toList();
      } else {
        AppLogger.error(
          'Failed to filter production by product',
          response['message'],
        );
        throw Exception(
          response['message'] ?? 'Failed to load production data',
        );
      }
    } catch (e) {
      AppLogger.error('Production product filter error', e);
      rethrow;
    }
  }
}
