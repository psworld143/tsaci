import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

class UserService {
  Future<List<UserModel>> getAllUsers() async {
    try {
      AppLogger.info('Loading all users');

      final response = await ApiService.get(ApiConstants.users);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersJson = response['data'];
        final users = usersJson
            .map((json) => UserModel.fromJson(json))
            .toList();

        AppLogger.info('Users loaded successfully', {'count': users.length});
        return users;
      }

      throw Exception(response['message'] ?? 'Failed to load users');
    } catch (e) {
      AppLogger.error('Error loading users', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      AppLogger.info('Creating user', {'email': email, 'role': role});

      final response = await ApiService.post(ApiConstants.users, {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create user');
      }

      AppLogger.info('User created successfully', {'email': email});
    } catch (e) {
      AppLogger.error('Error creating user', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> updateUser({
    required int userId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      AppLogger.info('Updating user', {'user_id': userId});

      final response = await ApiService.put(ApiConstants.userById(userId), {
        'name': name,
        'email': email,
        'role': role,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update user');
      }

      AppLogger.info('User updated successfully', {'user_id': userId});
    } catch (e) {
      AppLogger.error('Error updating user', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> resetPassword(int userId, String newPassword) async {
    try {
      AppLogger.info('Resetting password', {'user_id': userId});

      final response = await ApiService.post(
        '${ApiConstants.baseUrl}/users/reset-password/$userId',
        {'new_password': newPassword},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to reset password');
      }

      AppLogger.info('Password reset successfully', {'user_id': userId});
    } catch (e) {
      AppLogger.error('Error resetting password', {'error': e.toString()});
      rethrow;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      AppLogger.info('Deleting user', {'user_id': userId});

      final response = await ApiService.delete(ApiConstants.userById(userId));

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete user');
      }

      AppLogger.info('User deleted successfully', {'user_id': userId});
    } catch (e) {
      AppLogger.error('Error deleting user', {'error': e.toString()});
      rethrow;
    }
  }
}
