import '../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

class ProductAdminService {
  Future<List<ProductModel>> getAllProducts() async {
    try {
      AppLogger.info('Loading all products');

      final response = await ApiService.get(
        '${ApiConstants.baseUrl}/products/getAll',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> productsJson = response['data'];
        final products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();

        AppLogger.info('Products loaded successfully', {
          'count': products.length,
        });
        return products;
      }

      throw Exception(response['message'] ?? 'Failed to load products');
    } catch (e) {
      AppLogger.error('Error loading products', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> createProduct({
    required String name,
    required String category,
    required double price,
    required String unit,
  }) async {
    try {
      AppLogger.info('Creating product', {'name': name});

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/products/create',
        {'name': name, 'category': category, 'price': price, 'unit': unit},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create product');
      }

      AppLogger.info('Product created successfully', {'name': name});
    } catch (e) {
      AppLogger.error('Error creating product', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    required String category,
    required double price,
    required String unit,
  }) async {
    try {
      AppLogger.info('Updating product', {'product_id': productId});

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/products/update/$productId',
        {'name': name, 'category': category, 'price': price, 'unit': unit},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update product');
      }

      AppLogger.info('Product updated successfully', {'product_id': productId});
    } catch (e) {
      AppLogger.error('Error updating product', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      AppLogger.info('Deleting product', {'product_id': productId});

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/products/delete/$productId',
        {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete product');
      }

      AppLogger.info('Product deleted successfully', {'product_id': productId});
    } catch (e) {
      AppLogger.error('Error deleting product', {'error': e.toString()});
      rethrow;
    }
  }
}
