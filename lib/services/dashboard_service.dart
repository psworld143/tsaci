import '../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

/// Dashboard Service
class DashboardService {
  /// Get dashboard data
  static Future<DashboardData> getDashboardData() async {
    try {
      final response = await ApiService.get(ApiConstants.reportsDashboard);

      if (response['success'] == true) {
        AppLogger.success('Dashboard data loaded');
        return DashboardData.fromJson(response['data']);
      } else {
        AppLogger.error('Failed to load dashboard data', response['message']);
        throw Exception(response['message'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      AppLogger.error('Dashboard service error', e);
      rethrow;
    }
  }
}
