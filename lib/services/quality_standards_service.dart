import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quality_standard_model.dart';
import '../utils/app_logger.dart';

/// Quality Standards Service - Local storage for quality standards
class QualityStandardsService {
  static const String _storageKey = 'quality_standards';

  /// Get all standards
  static Future<List<QualityStandard>> getAllStandards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final standardsJson = prefs.getString(_storageKey);

      if (standardsJson == null || standardsJson.isEmpty) {
        return _getDefaultStandards();
      }

      final List<dynamic> standardsList = json.decode(standardsJson);
      return standardsList
          .map((json) => QualityStandard.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error loading standards', e.toString());
      return _getDefaultStandards();
    }
  }

  /// Get standard by product ID
  static Future<QualityStandard?> getByProductId(int productId) async {
    final standards = await getAllStandards();
    try {
      return standards.firstWhere((s) => s.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Create or update standard
  static Future<bool> saveStandard(QualityStandard standard) async {
    try {
      final standards = await getAllStandards();

      // Check if standard exists for this product
      final existingIndex = standards.indexWhere(
        (s) => s.productId == standard.productId,
      );

      if (existingIndex != -1) {
        // Update existing
        standards[existingIndex] = standard;
      } else {
        // Add new
        standards.add(standard);
      }

      final prefs = await SharedPreferences.getInstance();
      final standardsJson = json.encode(
        standards.map((s) => s.toJson()).toList(),
      );

      await prefs.setString(_storageKey, standardsJson);

      AppLogger.success('Quality standard saved', standard.productName);
      return true;
    } catch (e) {
      AppLogger.error('Error saving standard', e.toString());
      return false;
    }
  }

  /// Delete standard
  static Future<bool> deleteStandard(int productId) async {
    try {
      final standards = await getAllStandards();
      standards.removeWhere((s) => s.productId == productId);

      final prefs = await SharedPreferences.getInstance();
      final standardsJson = json.encode(
        standards.map((s) => s.toJson()).toList(),
      );

      await prefs.setString(_storageKey, standardsJson);

      AppLogger.success('Standard deleted', productId.toString());
      return true;
    } catch (e) {
      AppLogger.error('Error deleting standard', e.toString());
      return false;
    }
  }

  /// Get default standards (initial data)
  static List<QualityStandard> _getDefaultStandards() {
    return [
      QualityStandard.getDefault(1, 'Coconut Shell Activated Carbon'),
      QualityStandard.getDefault(2, 'Rice Husk Activated Carbon'),
      QualityStandard.getDefault(3, 'Wood Chip Activated Carbon'),
    ];
  }

  /// Initialize standards if empty
  static Future<void> initializeDefaults() async {
    final standards = await getAllStandards();
    if (standards.isEmpty) {
      for (var standard in _getDefaultStandards()) {
        await saveStandard(standard);
      }
    }
  }
}
