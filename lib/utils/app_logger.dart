import 'dart:developer' as developer;

/// App Logger - Logs all API responses and errors to console
class AppLogger {
  static const String _prefix = '🔷 TSACI';
  static bool enabled = true;

  /// Log API request
  static void apiRequest(String method, String url, [dynamic body]) {
    if (!enabled) return;

    print('\n${'=' * 80}');
    print('$_prefix API REQUEST');
    print('${'=' * 80}');
    print('📤 Method: $method');
    print('🌐 URL: $url');
    if (body != null) {
      print('📦 Body: $body');
    }
    print('🕐 Time: ${DateTime.now()}');
    print('${'=' * 80}\n');
  }

  /// Log API response success
  static void apiResponse(String url, int statusCode, dynamic data) {
    if (!enabled) return;

    print('\n${'=' * 80}');
    print('$_prefix API RESPONSE - SUCCESS ✅');
    print('${'=' * 80}');
    print('🌐 URL: $url');
    print('📊 Status: $statusCode');
    print('✅ Success: true');
    if (data != null) {
      print('📦 Data: $data');
    }
    print('🕐 Time: ${DateTime.now()}');
    print('${'=' * 80}\n');
  }

  /// Log API error
  static void apiError(String url, String error, [dynamic details]) {
    if (!enabled) return;

    print('\n${'=' * 80}');
    print('$_prefix API ERROR - FAILED ❌');
    print('${'=' * 80}');
    print('🌐 URL: $url');
    print('❌ Error: $error');
    if (details != null) {
      print('📋 Details: $details');
    }
    print('🕐 Time: ${DateTime.now()}');
    print('${'=' * 80}\n');
  }

  /// Log info message
  static void info(String message, [dynamic data]) {
    if (!enabled) return;

    print('\n${'─' * 80}');
    print('$_prefix INFO ℹ️');
    print('${'─' * 80}');
    print('ℹ️  $message');
    if (data != null) {
      print('📋 Data: $data');
    }
    print('${'─' * 80}\n');
  }

  /// Log error
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!enabled) return;

    print('\n${'=' * 80}');
    print('$_prefix ERROR ❌');
    print('${'=' * 80}');
    print('❌ Message: $message');
    if (error != null) {
      print('🔴 Error: $error');
    }
    if (stackTrace != null) {
      print('📍 Stack Trace:');
      print(stackTrace);
    }
    print('🕐 Time: ${DateTime.now()}');
    print('${'=' * 80}\n');
  }

  /// Log warning
  static void warning(String message, [dynamic data]) {
    if (!enabled) return;

    print('\n${'─' * 80}');
    print('$_prefix WARNING ⚠️');
    print('${'─' * 80}');
    print('⚠️  $message');
    if (data != null) {
      print('📋 Data: $data');
    }
    print('${'─' * 80}\n');
  }

  /// Log success
  static void success(String message, [dynamic data]) {
    if (!enabled) return;

    print('\n${'─' * 80}');
    print('$_prefix SUCCESS ✅');
    print('${'─' * 80}');
    print('✅ $message');
    if (data != null) {
      print('📋 Data: $data');
    }
    print('${'─' * 80}\n');
  }

  /// Log authentication
  static void auth(String action, bool success, [String? email]) {
    if (!enabled) return;

    print('\n${'=' * 80}');
    print('$_prefix AUTH ${success ? '✅' : '❌'}');
    print('${'=' * 80}');
    print('🔐 Action: $action');
    print('${success ? '✅' : '❌'} Success: $success');
    if (email != null) {
      print('👤 Email: $email');
    }
    print('🕐 Time: ${DateTime.now()}');
    print('${'=' * 80}\n');
  }

  /// Log offline sync
  static void sync(String message, int count, [bool success = true]) {
    if (!enabled) return;

    print('\n${'─' * 80}');
    print('$_prefix SYNC ${success ? '✅' : '⚠️'}');
    print('${'─' * 80}');
    print('🔄 $message');
    print('📊 Count: $count items');
    print('${'─' * 80}\n');
  }

  /// Developer log (for debugging)
  static void dev(String message, [dynamic data]) {
    if (!enabled) return;

    developer.log(message, name: 'TSACI', time: DateTime.now(), error: data);
  }
}
