import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/batch_template_model.dart';
import '../utils/app_logger.dart';

/// Batch Template Service - Local storage for batch templates
class BatchTemplateService {
  static const String _storageKey = 'batch_templates';

  /// Get all templates
  static Future<List<BatchTemplate>> getAllTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_storageKey);

      if (templatesJson == null || templatesJson.isEmpty) {
        return [];
      }

      final List<dynamic> templatesList = json.decode(templatesJson);
      return templatesList.map((json) => BatchTemplate.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error loading templates', e.toString());
      return [];
    }
  }

  /// Save template
  static Future<bool> saveTemplate(BatchTemplate template) async {
    try {
      final templates = await getAllTemplates();

      // Add new template with auto-generated ID
      final newTemplate = BatchTemplate(
        templateId: templates.isEmpty
            ? 1
            : (templates
                      .map((t) => t.templateId ?? 0)
                      .reduce((a, b) => a > b ? a : b) +
                  1),
        templateName: template.templateName,
        productId: template.productId,
        productName: template.productName,
        targetQuantity: template.targetQuantity,
        unit: template.unit,
        supervisorIds: template.supervisorIds,
        supervisorNames: template.supervisorNames,
        workerIds: template.workerIds,
        workerNames: template.workerNames,
        notes: template.notes,
        createdAt: DateTime.now(),
      );

      templates.add(newTemplate);

      final prefs = await SharedPreferences.getInstance();
      final templatesJson = json.encode(
        templates.map((t) => t.toJson()).toList(),
      );

      await prefs.setString(_storageKey, templatesJson);

      AppLogger.success('Template saved', template.templateName);
      return true;
    } catch (e) {
      AppLogger.error('Error saving template', e.toString());
      return false;
    }
  }

  /// Delete template
  static Future<bool> deleteTemplate(int templateId) async {
    try {
      final templates = await getAllTemplates();
      templates.removeWhere((t) => t.templateId == templateId);

      final prefs = await SharedPreferences.getInstance();
      final templatesJson = json.encode(
        templates.map((t) => t.toJson()).toList(),
      );

      await prefs.setString(_storageKey, templatesJson);

      AppLogger.info('Template deleted', {'template_id': templateId});
      return true;
    } catch (e) {
      AppLogger.error('Error deleting template', e.toString());
      return false;
    }
  }

  /// Get template by ID
  static Future<BatchTemplate?> getTemplateById(int templateId) async {
    try {
      final templates = await getAllTemplates();
      return templates.firstWhere(
        (t) => t.templateId == templateId,
        orElse: () => throw Exception('Template not found'),
      );
    } catch (e) {
      AppLogger.error('Error getting template', e.toString());
      return null;
    }
  }

  /// Update template
  static Future<bool> updateTemplate(BatchTemplate template) async {
    try {
      final templates = await getAllTemplates();
      final index = templates.indexWhere(
        (t) => t.templateId == template.templateId,
      );

      if (index == -1) {
        return false;
      }

      templates[index] = template;

      final prefs = await SharedPreferences.getInstance();
      final templatesJson = json.encode(
        templates.map((t) => t.toJson()).toList(),
      );

      await prefs.setString(_storageKey, templatesJson);

      AppLogger.success('Template updated', template.templateName);
      return true;
    } catch (e) {
      AppLogger.error('Error updating template', e.toString());
      return false;
    }
  }
}
