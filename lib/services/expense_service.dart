import '../core/constants/api_constants.dart';
import '../models/expense_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

class ExpenseService {
  Future<List<ExpenseModel>> getAllExpenses({int limit = 100}) async {
    try {
      AppLogger.info('Loading all expenses');

      final response = await ApiService.get(
        '${ApiConstants.baseUrl}/expenses/getAll?limit=$limit',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> expensesJson = response['data'];
        final expenses = expensesJson
            .map((json) => ExpenseModel.fromJson(json))
            .toList();

        AppLogger.info('Expenses loaded successfully', {
          'count': expenses.length,
        });
        return expenses;
      }

      throw Exception(response['message'] ?? 'Failed to load expenses');
    } catch (e) {
      AppLogger.error('Error loading expenses', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> createExpense({
    required String category,
    required double amount,
    required String date,
    String? description,
    String? department,
  }) async {
    try {
      AppLogger.info('Creating expense', {
        'category': category,
        'amount': amount,
      });

      final response =
          await ApiService.post('${ApiConstants.baseUrl}/expenses/create', {
            'category': category,
            'amount': amount,
            'date': date,
            'description': description,
            'department': department,
          });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create expense');
      }

      AppLogger.info('Expense created successfully');
    } catch (e) {
      AppLogger.error('Error creating expense', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateExpense({
    required int expenseId,
    required String category,
    required double amount,
    required String date,
    String? description,
    String? department,
  }) async {
    try {
      AppLogger.info('Updating expense', {'expense_id': expenseId});

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/expenses/update/$expenseId',
        {
          'category': category,
          'amount': amount,
          'date': date,
          'description': description,
          'department': department,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update expense');
      }

      AppLogger.info('Expense updated successfully');
    } catch (e) {
      AppLogger.error('Error updating expense', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      AppLogger.info('Deleting expense', {'expense_id': expenseId});

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/expenses/delete/$expenseId',
        {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete expense');
      }

      AppLogger.info('Expense deleted successfully');
    } catch (e) {
      AppLogger.error('Error deleting expense', {'error': e.toString()});
      rethrow;
    }
  }
}
