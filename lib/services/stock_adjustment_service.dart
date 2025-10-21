import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/stock_adjustment_model.dart';
import '../utils/app_logger.dart';

/// Stock Adjustment Service - Local storage for stock adjustments
class StockAdjustmentService {
  static const String _storageKey = 'stock_adjustments';

  /// Get all adjustments
  static Future<List<StockAdjustment>> getAllAdjustments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adjustmentsJson = prefs.getString(_storageKey);

      if (adjustmentsJson == null || adjustmentsJson.isEmpty) {
        return [];
      }

      final List<dynamic> adjustmentsList = json.decode(adjustmentsJson);
      return adjustmentsList
          .map((json) => StockAdjustment.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error loading adjustments', e.toString());
      return [];
    }
  }

  /// Record adjustment
  static Future<bool> recordAdjustment(StockAdjustment adjustment) async {
    try {
      final adjustments = await getAllAdjustments();

      // Add new adjustment with auto-generated ID
      final newAdjustment = StockAdjustment(
        adjustmentId: adjustments.isEmpty
            ? 1
            : (adjustments
                      .map((a) => a.adjustmentId ?? 0)
                      .reduce((a, b) => a > b ? a : b) +
                  1),
        inventoryId: adjustment.inventoryId,
        productName: adjustment.productName,
        adjustmentType: adjustment.adjustmentType,
        quantity: adjustment.quantity,
        reason: adjustment.reason,
        adjustedBy: adjustment.adjustedBy,
        adjustedByName: adjustment.adjustedByName,
        createdAt: DateTime.now(),
      );

      adjustments.insert(0, newAdjustment); // Add to beginning

      final prefs = await SharedPreferences.getInstance();
      final adjustmentsJson = json.encode(
        adjustments.map((a) => a.toJson()).toList(),
      );

      await prefs.setString(_storageKey, adjustmentsJson);

      AppLogger.success('Stock adjustment recorded', adjustment.productName);
      return true;
    } catch (e) {
      AppLogger.error('Error recording adjustment', e.toString());
      return false;
    }
  }

  /// Get adjustments by inventory ID
  static Future<List<StockAdjustment>> getByInventoryId(int inventoryId) async {
    final adjustments = await getAllAdjustments();
    return adjustments.where((a) => a.inventoryId == inventoryId).toList();
  }

  /// Get adjustments by type
  static Future<List<StockAdjustment>> getByType(String type) async {
    final adjustments = await getAllAdjustments();
    return adjustments
        .where((a) => a.adjustmentType.toUpperCase() == type.toUpperCase())
        .toList();
  }

  /// Get adjustments by date range
  static Future<List<StockAdjustment>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final adjustments = await getAllAdjustments();
    return adjustments.where((a) {
      return a.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          a.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}
