import '../models/production_batch_model.dart';
import '../core/constants/api_constants.dart';
import 'api_service.dart';
import '../utils/app_logger.dart';

/// Batch Management Service
/// Integrated with backend API
class BatchService {
  /// Get all batches
  static Future<List<ProductionBatch>> getAllBatches() async {
    try {
      AppLogger.info('Fetching all batches from API');
      final response = await ApiService.get(ApiConstants.batches);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> batchesJson = response['data'];
        final batches = batchesJson
            .map((json) => ProductionBatch.fromJson(json))
            .toList();
        AppLogger.info('Loaded ${batches.length} batches');
        return batches;
      }

      AppLogger.warning('No batches found or API returned error');
      return [];
    } catch (e) {
      AppLogger.error('Error loading batches', e);
      return [];
    }
  }

  /// Create new batch
  static Future<Map<String, dynamic>> createBatch(
    Map<String, dynamic> batchData,
  ) async {
    try {
      AppLogger.info('Creating new batch: ${batchData['product_id']}');
      final response = await ApiService.post(ApiConstants.batches, batchData);

      if (response['success'] == true) {
        AppLogger.success(
          'Batch created successfully: ${response['batch_number']}',
        );
        return {
          'success': true,
          'batch_id': response['batch_id'],
          'batch_number': response['batch_number'],
          'message': response['message'],
        };
      }

      AppLogger.warning('Failed to create batch: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to create batch',
      };
    } catch (e) {
      AppLogger.error('Error creating batch', e);
      return {'success': false, 'message': 'Failed to create batch: $e'};
    }
  }

  /// Update batch
  static Future<Map<String, dynamic>> updateBatch(
    int batchId,
    Map<String, dynamic> batchData,
  ) async {
    try {
      AppLogger.info('Updating batch: $batchId');
      final response = await ApiService.put(
        ApiConstants.batchById(batchId),
        batchData,
      );

      if (response['success'] == true) {
        AppLogger.success('Batch updated successfully');
        return {'success': true, 'message': response['message']};
      }

      AppLogger.warning('Failed to update batch: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update batch',
      };
    } catch (e) {
      AppLogger.error('Error updating batch', e);
      return {'success': false, 'message': 'Failed to update batch: $e'};
    }
  }

  /// Delete batch
  static Future<Map<String, dynamic>> deleteBatch(int batchId) async {
    try {
      AppLogger.info('Deleting batch: $batchId');
      final response = await ApiService.delete(ApiConstants.batchById(batchId));

      if (response['success'] == true) {
        AppLogger.success('Batch deleted successfully');
        return {'success': true, 'message': response['message']};
      }

      AppLogger.warning('Failed to delete batch: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to delete batch',
      };
    } catch (e) {
      AppLogger.error('Error deleting batch', e);
      return {'success': false, 'message': 'Failed to delete batch: $e'};
    }
  }

  /// Update batch stage
  static Future<Map<String, dynamic>> updateStage(
    int batchId,
    String stage,
  ) async {
    try {
      AppLogger.info('Updating batch stage: $batchId -> $stage');
      final response = await ApiService.post(ApiConstants.batchStage(batchId), {
        'stage': stage,
      });

      if (response['success'] == true) {
        AppLogger.success('Batch stage updated successfully');
        return {'success': true, 'message': response['message']};
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update stage',
      };
    } catch (e) {
      AppLogger.error('Error updating batch stage', e);
      return {'success': false, 'message': 'Failed to update stage: $e'};
    }
  }

  /// Update batch status
  static Future<Map<String, dynamic>> updateStatus(
    int batchId,
    String status,
  ) async {
    try {
      AppLogger.info('Updating batch status: $batchId -> $status');
      final response = await ApiService.post(
        ApiConstants.batchStatus(batchId),
        {'status': status},
      );

      if (response['success'] == true) {
        AppLogger.success('Batch status updated successfully');
        return {'success': true, 'message': response['message']};
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to update status',
      };
    } catch (e) {
      AppLogger.error('Error updating batch status', e);
      return {'success': false, 'message': 'Failed to update status: $e'};
    }
  }

  /// Get batches by status
  static Future<List<ProductionBatch>> getBatchesByStatus(String status) async {
    final batches = await getAllBatches();
    return batches
        .where((b) => b.status.toLowerCase() == status.toLowerCase())
        .toList();
  }
}
