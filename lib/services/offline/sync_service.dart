import 'package:connectivity_plus/connectivity_plus.dart';
import '../../utils/app_logger.dart';
import '../api_service.dart';
import '../../core/constants/api_constants.dart';
import 'offline_storage_service.dart';

/// Sync Service for offline data
class SyncService {
  /// Check if device is online
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Sync all offline production data
  static Future<SyncResult> syncOfflineData() async {
    final offlineData = await OfflineStorageService.getOfflineProductions();

    if (offlineData.isEmpty) {
      AppLogger.info('No offline data to sync');
      return SyncResult(success: 0, failed: 0, total: 0);
    }

    AppLogger.sync('Starting sync', offlineData.length);

    int successCount = 0;
    int failedCount = 0;
    final List<int> successIndices = [];

    for (int i = 0; i < offlineData.length; i++) {
      final productionData = offlineData[i];

      try {
        // Remove offline metadata before sending
        final dataToSend = Map<String, dynamic>.from(productionData);
        dataToSend.remove('offline_saved_at');

        await ApiService.post(ApiConstants.production, dataToSend);

        successCount++;
        successIndices.add(i);
      } catch (e) {
        AppLogger.warning('Sync failed for item ${i + 1}', e.toString());
        failedCount++;
      }
    }

    // Remove successfully synced items (in reverse order to maintain indices)
    for (int i = successIndices.length - 1; i >= 0; i--) {
      await OfflineStorageService.removeOfflineItem(successIndices[i]);
    }

    final result = SyncResult(
      success: successCount,
      failed: failedCount,
      total: offlineData.length,
    );

    AppLogger.sync(
      'Sync completed: $successCount success, $failedCount failed',
      offlineData.length,
      result.allSuccess,
    );

    return result;
  }

  /// Auto sync when online
  static Future<void> autoSync() async {
    if (await isOnline()) {
      await syncOfflineData();
    }
  }
}

class SyncResult {
  final int success;
  final int failed;
  final int total;

  SyncResult({
    required this.success,
    required this.failed,
    required this.total,
  });

  bool get hasFailures => failed > 0;
  bool get allSuccess => success == total;
}
