import '../core/constants/api_constants.dart';
import '../models/inventory_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

class InventoryService {
  Future<List<InventoryModel>> getAllInventory() async {
    try {
      AppLogger.info('Loading all inventory');

      final response = await ApiService.get(ApiConstants.inventory);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> inventoryJson = response['data'];
        final inventory = inventoryJson
            .map((json) => InventoryModel.fromJson(json))
            .toList();

        AppLogger.info('Inventory loaded successfully', {
          'count': inventory.length,
        });
        return inventory;
      }

      throw Exception(response['message'] ?? 'Failed to load inventory');
    } catch (e) {
      AppLogger.error('Error loading inventory', {'error': e.toString()});
      rethrow;
    }
  }

  Future<List<InventoryModel>> getLowStockItems() async {
    try {
      AppLogger.info('Loading low stock items');

      final response = await ApiService.get(ApiConstants.inventoryLowStock);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> inventoryJson = response['data'];
        final inventory = inventoryJson
            .map((json) => InventoryModel.fromJson(json))
            .toList();

        AppLogger.info('Low stock items loaded', {'count': inventory.length});
        return inventory;
      }

      throw Exception(response['message'] ?? 'Failed to load low stock items');
    } catch (e) {
      AppLogger.error('Error loading low stock items', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> createInventory({
    required int productId,
    required double quantity,
    required String location,
    required double minimumThreshold,
  }) async {
    try {
      AppLogger.info('Creating inventory', {'product_id': productId});

      final response = await ApiService.post(ApiConstants.inventory, {
        'product_id': productId,
        'quantity': quantity,
        'location': location,
        'minimum_threshold': minimumThreshold,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create inventory');
      }

      AppLogger.info('Inventory created successfully');
    } catch (e) {
      AppLogger.error('Error creating inventory', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateInventory({
    required int inventoryId,
    required double quantity,
    required String location,
    required double minimumThreshold,
  }) async {
    try {
      AppLogger.info('Updating inventory', {'inventory_id': inventoryId});

      final response =
          await ApiService.put('${ApiConstants.inventory}/$inventoryId', {
            'quantity': quantity,
            'location': location,
            'minimum_threshold': minimumThreshold,
          });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update inventory');
      }

      AppLogger.info('Inventory updated successfully');
    } catch (e) {
      AppLogger.error('Error updating inventory', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> deleteInventory(int inventoryId) async {
    try {
      AppLogger.info('Deleting inventory', {'inventory_id': inventoryId});

      final response = await ApiService.delete(
        '${ApiConstants.inventory}/$inventoryId',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete inventory');
      }

      AppLogger.info('Inventory deleted successfully');
    } catch (e) {
      AppLogger.error('Error deleting inventory', {'error': e.toString()});
      rethrow;
    }
  }
}
