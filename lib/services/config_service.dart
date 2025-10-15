import '../core/constants/api_constants.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

class ConfigService {
  Future<Map<String, dynamic>> getAllConfigs() async {
    try {
      AppLogger.info('Loading system configurations');

      final response = await ApiService.get(
        '${ApiConstants.baseUrl}/config/getAll',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> configsJson = response['data'];

        // Convert to map for easy access
        final Map<String, dynamic> configs = {};
        for (var config in configsJson) {
          configs[config['config_key']] = config['config_value'];
        }

        AppLogger.info('Configs loaded successfully', {
          'count': configsJson.length,
        });
        return configs;
      }

      throw Exception(response['message'] ?? 'Failed to load configurations');
    } catch (e) {
      AppLogger.error('Error loading configurations', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateConfig(String key, dynamic value) async {
    try {
      AppLogger.info('Updating config', {'key': key});

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/config/update',
        {'config_key': key, 'config_value': value},
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'Failed to update configuration',
        );
      }

      AppLogger.info('Config updated successfully', {'key': key});
    } catch (e) {
      AppLogger.error('Error updating config', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateBulk(Map<String, dynamic> configs) async {
    try {
      AppLogger.info('Updating bulk configs', {'count': configs.length});

      final configsList = configs.entries.map((entry) {
        return {'config_key': entry.key, 'config_value': entry.value};
      }).toList();

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/config/updateBulk',
        {'configs': configsList},
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'Failed to update configurations',
        );
      }

      AppLogger.info('Bulk configs updated successfully');
    } catch (e) {
      AppLogger.error('Error updating bulk configs', {'error': e.toString()});
      rethrow;
    }
  }
}
