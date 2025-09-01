import 'package:flutter/foundation.dart';

/// A utility class for logging performance monitor events and errors.
class PerfMonitorLogger {
  static const String _tag = 'FlutterPerfMonitor';

  /// Logs debug information.
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] DEBUG: $message');
      if (error != null) {
        print('[$_tag] ERROR: $error');
        if (stackTrace != null) {
          print('[$_tag] STACK: $stackTrace');
        }
      }
    }
  }

  /// Logs informational messages.
  static void info(String message) {
    if (kDebugMode) {
      print('[$_tag] INFO: $message');
    }
  }

  /// Logs warning messages.
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      print('[$_tag] WARNING: $message');
      if (error != null) {
        print('[$_tag] ERROR: $error');
      }
    }
  }

  /// Logs error messages.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] ERROR: $message');
      if (error != null) {
        print('[$_tag] ERROR DETAILS: $error');
        if (stackTrace != null) {
          print('[$_tag] STACK TRACE: $stackTrace');
        }
      }
    }
  }

  /// Logs performance metrics for debugging.
  static void logMetrics({
    required double fps,
    required int memoryUsage,
    required double cpuUsage,
    required double frameTime,
  }) {
    if (kDebugMode) {
      print(
        '[$_tag] METRICS: FPS=$fps, Memory=${(memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB, '
        'CPU=${cpuUsage.toStringAsFixed(1)}%, FrameTime=${frameTime.toStringAsFixed(2)}ms',
      );
    }
  }
}
