import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = 'BiogasApp';
  
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag] ${tag ?? 'DEBUG'}: $message');
    }
  }
  
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag] ${tag ?? 'INFO'}: $message');
    }
  }
  
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('⚠️ [$_tag] ${tag ?? 'WARNING'}: $message');
    }
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      debugPrint('❌ [$_tag] ${tag ?? 'ERROR'}: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
}
