import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quality_inspection_model.dart';
import '../utils/app_logger.dart';

/// Quality Inspection Service - Local storage for inspections
class QualityInspectionService {
  static const String _storageKey = 'quality_inspections';

  /// Get all inspections
  static Future<List<QualityInspection>> getAllInspections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inspectionsJson = prefs.getString(_storageKey);

      if (inspectionsJson == null || inspectionsJson.isEmpty) {
        return [];
      }

      final List<dynamic> inspectionsList = json.decode(inspectionsJson);
      return inspectionsList
          .map((json) => QualityInspection.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error loading inspections', e.toString());
      return [];
    }
  }

  /// Get inspection by ID
  static Future<QualityInspection?> getInspectionById(int id) async {
    final inspections = await getAllInspections();
    try {
      return inspections.firstWhere((i) => i.inspectionId == id);
    } catch (e) {
      return null;
    }
  }

  /// Get inspections by status
  static Future<List<QualityInspection>> getByStatus(String status) async {
    final inspections = await getAllInspections();
    return inspections.where((i) => i.status == status).toList();
  }

  /// Get inspections by batch ID
  static Future<List<QualityInspection>> getByBatchId(int batchId) async {
    final inspections = await getAllInspections();
    return inspections.where((i) => i.batchId == batchId).toList();
  }

  /// Create new inspection
  static Future<bool> createInspection(QualityInspection inspection) async {
    try {
      final inspections = await getAllInspections();

      // Add new inspection with auto-generated ID
      final newInspection = QualityInspection(
        inspectionId: inspections.isEmpty
            ? 1
            : (inspections
                      .map((i) => i.inspectionId ?? 0)
                      .reduce((a, b) => a > b ? a : b) +
                  1),
        batchId: inspection.batchId,
        batchNumber: inspection.batchNumber,
        productName: inspection.productName,
        inspectorId: inspection.inspectorId,
        inspectorName: inspection.inspectorName,
        inspectionDate: inspection.inspectionDate,
        tests: inspection.tests,
        status: inspection.status,
        remarks: inspection.remarks,
        defects: inspection.defects,
        createdAt: DateTime.now(),
      );

      inspections.insert(0, newInspection); // Add to beginning

      final prefs = await SharedPreferences.getInstance();
      final inspectionsJson = json.encode(
        inspections.map((i) => i.toJson()).toList(),
      );

      await prefs.setString(_storageKey, inspectionsJson);

      AppLogger.success('Quality inspection created', inspection.batchNumber);
      return true;
    } catch (e) {
      AppLogger.error('Error creating inspection', e.toString());
      return false;
    }
  }

  /// Update inspection
  static Future<bool> updateInspection(QualityInspection inspection) async {
    try {
      final inspections = await getAllInspections();
      final index = inspections.indexWhere(
        (i) => i.inspectionId == inspection.inspectionId,
      );

      if (index == -1) {
        AppLogger.error(
          'Inspection not found',
          inspection.inspectionId.toString(),
        );
        return false;
      }

      // Update with new data
      inspections[index] = QualityInspection(
        inspectionId: inspection.inspectionId,
        batchId: inspection.batchId,
        batchNumber: inspection.batchNumber,
        productName: inspection.productName,
        inspectorId: inspection.inspectorId,
        inspectorName: inspection.inspectorName,
        inspectionDate: inspection.inspectionDate,
        tests: inspection.tests,
        status: inspection.status,
        remarks: inspection.remarks,
        defects: inspection.defects,
        createdAt: inspection.createdAt,
        updatedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final inspectionsJson = json.encode(
        inspections.map((i) => i.toJson()).toList(),
      );

      await prefs.setString(_storageKey, inspectionsJson);

      AppLogger.success('Inspection updated', inspection.batchNumber);
      return true;
    } catch (e) {
      AppLogger.error('Error updating inspection', e.toString());
      return false;
    }
  }

  /// Delete inspection
  static Future<bool> deleteInspection(int inspectionId) async {
    try {
      final inspections = await getAllInspections();
      inspections.removeWhere((i) => i.inspectionId == inspectionId);

      final prefs = await SharedPreferences.getInstance();
      final inspectionsJson = json.encode(
        inspections.map((i) => i.toJson()).toList(),
      );

      await prefs.setString(_storageKey, inspectionsJson);

      AppLogger.success('Inspection deleted', inspectionId.toString());
      return true;
    } catch (e) {
      AppLogger.error('Error deleting inspection', e.toString());
      return false;
    }
  }

  /// Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final inspections = await getAllInspections();

    final pending = inspections.where((i) => i.isPending).length;
    final approved = inspections.where((i) => i.isApproved).length;
    final rejected = inspections.where((i) => i.isRejected).length;
    final total = inspections.length;

    final passRate = total > 0
        ? (approved / total * 100).toStringAsFixed(1)
        : '0.0';

    final totalDefects = inspections.fold<int>(
      0,
      (sum, i) => sum + i.defectCount,
    );

    final criticalDefects = inspections.fold<int>(
      0,
      (sum, i) => sum + i.criticalDefects,
    );

    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'total': total,
      'pass_rate': passRate,
      'total_defects': totalDefects,
      'critical_defects': criticalDefects,
    };
  }

  /// Get inspections by date range
  static Future<List<QualityInspection>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final inspections = await getAllInspections();
    return inspections.where((i) {
      return i.inspectionDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          i.inspectionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}
