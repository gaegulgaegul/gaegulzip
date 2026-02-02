import 'package:flutter/foundation.dart';

/// 간단한 로깅 유틸리티
class Logger {
  /// 정보 로그
  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  /// 경고 로그
  static void warn(String message) {
    if (kDebugMode) {
      print('[WARN] $message');
    }
  }

  /// 에러 로그
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) {
        print('[ERROR] Error: $error');
      }
      if (stackTrace != null) {
        print('[ERROR] StackTrace: $stackTrace');
      }
    }
  }

  /// 디버그 로그
  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }
}
