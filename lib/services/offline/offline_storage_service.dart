import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_logger.dart';

/// Offline Storage Service for production data
class OfflineStorageService {
  static const String _productionKey = 'offline_production_data';

  /// Save production data offline
  static Future<void> saveProductionOffline(
    Map<String, dynamic> productionData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineData = prefs.getStringList(_productionKey) ?? [];

    // Add timestamp for tracking
    productionData['offline_saved_at'] = DateTime.now().toIso8601String();

    offlineData.add(jsonEncode(productionData));
    await prefs.setStringList(_productionKey, offlineData);

    AppLogger.warning('Production data saved offline', {
      'product_id': productionData['product_id'],
      'total_offline': offlineData.length,
    });
  }

  /// Get all offline production data
  static Future<List<Map<String, dynamic>>> getOfflineProductions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineData = prefs.getStringList(_productionKey) ?? [];

    return offlineData.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  /// Get count of offline items
  static Future<int> getOfflineCount() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineData = prefs.getStringList(_productionKey) ?? [];
    return offlineData.length;
  }

  /// Clear offline production data
  static Future<void> clearOfflineProductions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productionKey);
  }

  /// Remove specific offline item by index
  static Future<void> removeOfflineItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineData = prefs.getStringList(_productionKey) ?? [];

    if (index >= 0 && index < offlineData.length) {
      offlineData.removeAt(index);
      await prefs.setStringList(_productionKey, offlineData);
    }
  }
}
