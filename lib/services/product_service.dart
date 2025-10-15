import '../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

/// Product Service
class ProductService {
  /// Get all products
  static Future<List<ProductModel>> getAll() async {
    try {
      final response = await ApiService.get(ApiConstants.products);

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        AppLogger.success('Products loaded', '${data.length} products');
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        AppLogger.error('Failed to load products', response['message']);
        throw Exception(response['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      AppLogger.error('Product service error', e);
      rethrow;
    }
  }
}
