import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../exceptions/perf_monitor_exceptions.dart';
import '../utils/logger.dart';
import 'perf_monitor_interface.dart';

/// Platform-specific implementation for performance monitoring using method channels.
class MethodChannelPerfMonitor implements PerfMonitorInterface {
  static const MethodChannel _channel = MethodChannel('flutter_perf_monitor');

  /// Gets the current memory usage in bytes.
  @override
  Future<int> getMemoryUsage() async {
    try {
      int result;
      if (Platform.isAndroid) {
        result = await _getAndroidMemoryUsage();
      } else if (Platform.isIOS) {
        result = await _getIOSMemoryUsage();
      } else if (Platform.isWindows) {
        result = await _getWindowsMemoryUsage();
      } else if (Platform.isMacOS) {
        result = await _getMacOSMemoryUsage();
      } else if (Platform.isLinux) {
        result = await _getLinuxMemoryUsage();
      } else {
        // Fallback for unsupported platforms
        result = await _getFallbackMemoryUsage();
      }

      PerfMonitorLogger.debug(
        'Memory usage retrieved: ${(result / 1024 / 1024).toStringAsFixed(1)}MB',
      );
      return result;
    } on PlatformException catch (e) {
      PerfMonitorLogger.error('Platform error getting memory usage', e);
      throw MemoryMonitoringException(
        'Failed to get memory usage: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      PerfMonitorLogger.error(
        'Unexpected error getting memory usage',
        e,
        stackTrace,
      );
      return await _getFallbackMemoryUsage();
    }
  }

  /// Gets the current CPU usage percentage.
  @override
  Future<double> getCPUUsage() async {
    try {
      double result;
      if (Platform.isAndroid) {
        result = await _getAndroidCPUUsage();
      } else if (Platform.isIOS) {
        result = await _getIOSCPUUsage();
      } else if (Platform.isWindows) {
        result = await _getWindowsCPUUsage();
      } else if (Platform.isMacOS) {
        result = await _getMacOSCPUUsage();
      } else if (Platform.isLinux) {
        result = await _getLinuxCPUUsage();
      } else {
        // Fallback for unsupported platforms
        result = await _getFallbackCPUUsage();
      }

      PerfMonitorLogger.debug(
        'CPU usage retrieved: ${result.toStringAsFixed(1)}%',
      );
      return result;
    } on PlatformException catch (e) {
      PerfMonitorLogger.error('Platform error getting CPU usage', e);
      throw CPUMonitoringException(
        'Failed to get CPU usage: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      PerfMonitorLogger.error(
        'Unexpected error getting CPU usage',
        e,
        stackTrace,
      );
      return await _getFallbackCPUUsage();
    }
  }

  /// Gets the total available memory in bytes.
  @override
  Future<int> getTotalMemory() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidTotalMemory();
      } else if (Platform.isIOS) {
        return await _getIOSTotalMemory();
      } else if (Platform.isWindows) {
        return await _getWindowsTotalMemory();
      } else if (Platform.isMacOS) {
        return await _getMacOSTotalMemory();
      } else if (Platform.isLinux) {
        return await _getLinuxTotalMemory();
      } else {
        return await _getFallbackTotalMemory();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting total memory: $e');
      }
      return await _getFallbackTotalMemory();
    }
  }

  /// Gets the available memory in bytes.
  @override
  Future<int> getAvailableMemory() async {
    try {
      final total = await getTotalMemory();
      final used = await getMemoryUsage();
      return total - used;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available memory: $e');
      }
      return 0;
    }
  }

  // Android-specific implementations
  static Future<int> _getAndroidMemoryUsage() async {
    final result = await _channel.invokeMethod<int>('getAndroidMemoryUsage');
    return result ?? 0;
  }

  static Future<double> _getAndroidCPUUsage() async {
    final result = await _channel.invokeMethod<double>('getAndroidCPUUsage');
    return result ?? 0.0;
  }

  static Future<int> _getAndroidTotalMemory() async {
    final result = await _channel.invokeMethod<int>('getAndroidTotalMemory');
    return result ?? 0;
  }

  // iOS-specific implementations
  static Future<int> _getIOSMemoryUsage() async {
    final result = await _channel.invokeMethod<int>('getIOSMemoryUsage');
    return result ?? 0;
  }

  static Future<double> _getIOSCPUUsage() async {
    final result = await _channel.invokeMethod<double>('getIOSCPUUsage');
    return result ?? 0.0;
  }

  static Future<int> _getIOSTotalMemory() async {
    final result = await _channel.invokeMethod<int>('getIOSTotalMemory');
    return result ?? 0;
  }

  // Windows-specific implementations
  static Future<int> _getWindowsMemoryUsage() async {
    final result = await _channel.invokeMethod<int>('getWindowsMemoryUsage');
    return result ?? 0;
  }

  static Future<double> _getWindowsCPUUsage() async {
    final result = await _channel.invokeMethod<double>('getWindowsCPUUsage');
    return result ?? 0.0;
  }

  static Future<int> _getWindowsTotalMemory() async {
    final result = await _channel.invokeMethod<int>('getWindowsTotalMemory');
    return result ?? 0;
  }

  // macOS-specific implementations
  static Future<int> _getMacOSMemoryUsage() async {
    final result = await _channel.invokeMethod<int>('getMacOSMemoryUsage');
    return result ?? 0;
  }

  static Future<double> _getMacOSCPUUsage() async {
    final result = await _channel.invokeMethod<double>('getMacOSCPUUsage');
    return result ?? 0.0;
  }

  static Future<int> _getMacOSTotalMemory() async {
    final result = await _channel.invokeMethod<int>('getMacOSTotalMemory');
    return result ?? 0;
  }

  // Linux-specific implementations
  static Future<int> _getLinuxMemoryUsage() async {
    final result = await _channel.invokeMethod<int>('getLinuxMemoryUsage');
    return result ?? 0;
  }

  static Future<double> _getLinuxCPUUsage() async {
    final result = await _channel.invokeMethod<double>('getLinuxCPUUsage');
    return result ?? 0.0;
  }

  static Future<int> _getLinuxTotalMemory() async {
    final result = await _channel.invokeMethod<int>('getLinuxTotalMemory');
    return result ?? 0;
  }

  // Fallback implementations for unsupported platforms or when native calls fail
  static Future<int> _getFallbackMemoryUsage() async {
    // Use ProcessInfo for basic memory estimation
    try {
      final info = ProcessInfo.currentRss;
      return info;
    } catch (e) {
      // Last resort: return a small placeholder value
      return 1024 * 1024; // 1MB
    }
  }

  static Future<double> _getFallbackCPUUsage() async {
    // Return a placeholder value when native monitoring is not available
    return 0.0;
  }

  static Future<int> _getFallbackTotalMemory() async {
    // Return a placeholder value when native monitoring is not available
    return 1024 * 1024 * 1024; // 1GB
  }
}

/// Creates a new MethodChannelPerfMonitor instance.
PerfMonitorInterface perfMonitorImpl() => MethodChannelPerfMonitor();
