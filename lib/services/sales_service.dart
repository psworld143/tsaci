import '../core/constants/api_constants.dart';
import '../models/sales_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

class SalesService {
  Future<List<SalesModel>> getAllSales({int limit = 100}) async {
    try {
      AppLogger.info('Loading all sales');

      final response = await ApiService.get(
        '${ApiConstants.sales}?limit=$limit',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> salesJson = response['data'];
        final sales = salesJson
            .map((json) => SalesModel.fromJson(json))
            .toList();

        AppLogger.info('Sales loaded successfully', {'count': sales.length});
        return sales;
      }

      throw Exception(response['message'] ?? 'Failed to load sales');
    } catch (e) {
      AppLogger.error('Error loading sales', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> createSale({
    required int customerId,
    required int productId,
    required int quantity,
    required double unitPrice,
    required String status,
    required String date,
  }) async {
    try {
      AppLogger.info('Creating sale', {
        'customer_id': customerId,
        'product_id': productId,
        'quantity': quantity,
      });

      final response = await ApiService.post(ApiConstants.sales, {
        'customer_id': customerId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'status': status,
        'date': date,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create sale');
      }

      AppLogger.info('Sale created successfully');
    } catch (e) {
      AppLogger.error('Error creating sale', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateSale({
    required int saleId,
    required int customerId,
    required int productId,
    required int quantity,
    required double unitPrice,
    required String status,
    required String date,
  }) async {
    try {
      AppLogger.info('Updating sale', {'sale_id': saleId});

      final response = await ApiService.put(ApiConstants.salesById(saleId), {
        'customer_id': customerId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'status': status,
        'date': date,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update sale');
      }

      AppLogger.info('Sale updated successfully');
    } catch (e) {
      AppLogger.error('Error updating sale', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateSaleStatus(int saleId, String status) async {
    try {
      AppLogger.info('Updating sale status', {
        'sale_id': saleId,
        'status': status,
      });

      final response = await ApiService.put(ApiConstants.salesById(saleId), {
        'status': status,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update sale status');
      }

      AppLogger.info('Sale status updated successfully');
    } catch (e) {
      AppLogger.error('Error updating sale status', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> deleteSale(int saleId) async {
    try {
      AppLogger.info('Deleting sale', {'sale_id': saleId});

      final response = await ApiService.delete(ApiConstants.salesById(saleId));

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete sale');
      }

      AppLogger.info('Sale deleted successfully');
    } catch (e) {
      AppLogger.error('Error deleting sale', {'error': e.toString()});
      rethrow;
    }
  }
}
