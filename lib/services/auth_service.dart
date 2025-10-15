import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication Service
class AuthService {
  /// Login
  static Future<UserModel> login(String email, String password) async {
    try {
      print('[AuthService] Starting login for: $email');
      final response = await ApiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      print('[AuthService] API Response: ${response['success']}');

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];

        print('[AuthService] User data received:');
        print('  - user_id: ${userData['user_id']}');
        print('  - name: ${userData['name']}');
        print('  - email: ${userData['email']}');
        print('  - role: ${userData['role']}');

        // Save token
        await StorageService.saveToken(token);
        print('[AuthService] Token saved');

        // Save user data
        await StorageService.saveUserData(
          userId: userData['user_id'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'],
        );
        print('[AuthService] User data saved to storage');

        AppLogger.auth('Login', true, email);
        return UserModel.fromJson(userData);
      } else {
        print('[AuthService] Login failed: ${response['message']}');
        AppLogger.auth('Login', false, email);
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('[AuthService] Exception: $e');
      AppLogger.auth('Login', false, email);
      rethrow;
    }
  }

  /// Logout
  static Future<void> logout() async {
    AppLogger.info('User logged out');
    await StorageService.clearAll();
  }

  /// Check if logged in
  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  /// Get current user
  static Future<UserModel?> getCurrentUser() async {
    final userId = await StorageService.getUserId();
    if (userId == null) return null;

    final name = await StorageService.getUserName();
    final email = await StorageService.getUserEmail();
    final role = await StorageService.getUserRole();

    if (name != null && email != null && role != null) {
      return UserModel(
        userId: userId,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
    }

    return null;
  }
}
