import '../models/material_withdrawal_model.dart';
import '../core/constants/api_constants.dart';
import 'api_service.dart';
import '../utils/app_logger.dart';

/// Material Withdrawal Service
/// Integrated with backend API
class MaterialWithdrawalService {
  /// Get all withdrawals
  static Future<List<MaterialWithdrawal>> getAllWithdrawals() async {
    try {
      AppLogger.info('Fetching all material withdrawals from API');
      final response = await ApiService.get(ApiConstants.withdrawals);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> withdrawalsJson = response['data'];
        final withdrawals = withdrawalsJson
            .map((json) => MaterialWithdrawal.fromJson(json))
            .toList();
        AppLogger.info('Loaded ${withdrawals.length} withdrawals');
        return withdrawals;
      }

      AppLogger.warning('No withdrawals found or API returned error');
      return [];
    } catch (e) {
      AppLogger.error('Error loading withdrawals', e);
      return [];
    }
  }

  /// Get pending withdrawals
  static Future<List<MaterialWithdrawal>> getPendingWithdrawals() async {
    final all = await getAllWithdrawals();
    return all.where((w) => w.status == 'pending').toList();
  }

  /// Create withdrawal request
  static Future<Map<String, dynamic>> createWithdrawal(
    Map<String, dynamic> withdrawalData,
  ) async {
    try {
      AppLogger.info('Creating withdrawal request');
      final response = await ApiService.post(
        ApiConstants.withdrawals,
        withdrawalData,
      );

      if (response['success'] == true) {
        AppLogger.success('Withdrawal request created successfully');
        return {
          'success': true,
          'withdrawal_id': response['withdrawal_id'],
          'message': response['message'],
        };
      }

      AppLogger.warning('Failed to create withdrawal: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to create withdrawal',
      };
    } catch (e) {
      AppLogger.error('Error creating withdrawal', e);
      return {'success': false, 'message': 'Failed to create withdrawal: $e'};
    }
  }

  /// Approve withdrawal (auto-deducts from inventory on backend)
  static Future<Map<String, dynamic>> approveWithdrawal(
    int withdrawalId,
    int approvedBy,
  ) async {
    try {
      AppLogger.info('Approving withdrawal: $withdrawalId');
      final response = await ApiService.post(
        ApiConstants.withdrawalApprove(withdrawalId),
        {'approved_by': approvedBy},
      );

      if (response['success'] == true) {
        AppLogger.success('Withdrawal approved and inventory deducted');
        return {
          'success': true,
          'message': response['message'] ?? 'Withdrawal approved successfully',
        };
      }

      AppLogger.warning('Failed to approve withdrawal: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to approve withdrawal',
      };
    } catch (e) {
      AppLogger.error('Error approving withdrawal', e);
      return {'success': false, 'message': 'Failed to approve withdrawal: $e'};
    }
  }

  /// Reject withdrawal
  static Future<Map<String, dynamic>> rejectWithdrawal(
    int withdrawalId,
    int approvedBy,
    String reason,
  ) async {
    try {
      AppLogger.info('Rejecting withdrawal: $withdrawalId');
      final response = await ApiService.post(
        ApiConstants.withdrawalReject(withdrawalId),
        {'approved_by': approvedBy, 'reason': reason},
      );

      if (response['success'] == true) {
        AppLogger.success('Withdrawal rejected');
        return {
          'success': true,
          'message': response['message'] ?? 'Withdrawal rejected successfully',
        };
      }

      AppLogger.warning('Failed to reject withdrawal: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to reject withdrawal',
      };
    } catch (e) {
      AppLogger.error('Error rejecting withdrawal', e);
      return {'success': false, 'message': 'Failed to reject withdrawal: $e'};
    }
  }
}
