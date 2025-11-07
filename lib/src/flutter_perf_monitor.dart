import 'dart:async';
// Conditional import for ProcessInfo (not available on web)
import 'dart:io' if (dart.library.html) 'flutter_perf_monitor_stub.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// JavaScript interop for web memory API (only available on web)
// Use stub on non-web platforms, dart:js on web
import 'flutter_perf_monitor_stub.dart' if (dart.library.html) 'dart:js' as js;
import 'models/fps_data.dart';
import 'models/memory_data.dart';
import 'models/performance_metrics.dart';

/// Main class for Flutter performance monitoring.
///
/// This class provides real-time performance monitoring capabilities including
/// FPS tracking, memory usage monitoring, and performance metrics collection.
class FlutterPerfMonitor {
  static FlutterPerfMonitor? _instance;

  /// Gets the singleton instance of FlutterPerfMonitor.
  ///
  /// This getter ensures only one instance exists throughout the app lifecycle.
  static FlutterPerfMonitor get instance =>
      _instance ??= FlutterPerfMonitor._();

  FlutterPerfMonitor._();

  bool _isInitialized = false;
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  final List<double> _fpsHistory = [];
  // Memory history tracking for future use
  // final List<int> _memoryHistory = [];

  DateTime? _lastFrameTime;
  int _frameCount = 0;
  double _currentFPS = 0.0;
  double _averageFPS = 0.0;
  double _minFPS = double.infinity;
  double _maxFPS = 0.0;

  int _peakMemoryUsage = 0;
  int _totalMemory = 0;
  int _availableMemory = 0;
  double _currentCpuUsage = 0.0;
  List<double> _perCoreCpuUsage = [];
  bool _hasLoggedMemoryWarning = false;
  static const MethodChannel _channel = MethodChannel('flutter_perf_monitor');

  final StreamController<PerformanceMetrics> _metricsController =
      StreamController<PerformanceMetrics>.broadcast();

  final StreamController<FPSData> _fpsController =
      StreamController<FPSData>.broadcast();

  final StreamController<MemoryData> _memoryController =
      StreamController<MemoryData>.broadcast();

  /// Stream of performance metrics updates
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  /// Stream of FPS data updates
  Stream<FPSData> get fpsStream => _fpsController.stream;

  /// Stream of memory data updates
  Stream<MemoryData> get memoryStream => _memoryController.stream;

  /// Initialize the performance monitor
  ///
  /// This method should be called before starting monitoring.
  /// It sets up the necessary callbacks and initializes the monitoring system.
  static Future<void> initialize() async {
    if (instance._isInitialized) return;

    instance._isInitialized = true;

    // Set up frame callback for FPS monitoring
    SchedulerBinding.instance.addPersistentFrameCallback((Duration timeStamp) {
      instance._onFrame(timeStamp);
    });

    if (kDebugMode) {
      debugPrint('FlutterPerfMonitor initialized successfully');
    }
  }

  /// Start performance monitoring
  ///
  /// Begins collecting performance metrics at regular intervals.
  /// The monitoring frequency can be adjusted by changing the [interval] parameter.
  static void startMonitoring({
    Duration interval = const Duration(milliseconds: 100),
  }) {
    if (!instance._isInitialized) {
      throw StateError(
        'FlutterPerfMonitor must be initialized before starting monitoring',
      );
    }

    if (instance._isMonitoring) return;

    instance._isMonitoring = true;
    instance._monitoringTimer = Timer.periodic(interval, (timer) async {
      await instance._collectMetrics();
    });

    if (kDebugMode) {
      debugPrint('Performance monitoring started');
    }
  }

  /// Stop performance monitoring
  ///
  /// Stops collecting performance metrics and cleans up resources.
  static void stopMonitoring() {
    if (!instance._isMonitoring) return;

    instance._isMonitoring = false;
    instance._monitoringTimer?.cancel();
    instance._monitoringTimer = null;

    if (kDebugMode) {
      debugPrint('Performance monitoring stopped');
    }
  }

  /// Get current FPS value
  static double getFPS() {
    return instance._currentFPS;
  }

  /// Get current memory usage in bytes
  static int getMemoryUsage() {
    return instance._getCurrentMemoryUsage();
  }

  /// Get current performance metrics
  static PerformanceMetrics getCurrentMetrics() {
    return instance._createPerformanceMetrics();
  }

  /// Get per-core CPU usage
  static List<double> getPerCoreCpuUsage() {
    return instance._perCoreCpuUsage;
  }

  /// Dispose of resources
  ///
  /// This method should be called when the monitor is no longer needed.
  static void dispose() {
    stopMonitoring();
    instance._metricsController.close();
    instance._fpsController.close();
    instance._memoryController.close();
    instance._isInitialized = false;
  }

  void _onFrame(Duration timeStamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration =
          now.difference(_lastFrameTime!).inMicroseconds / 1000.0;
      if (frameDuration > 0) {
        _currentFPS = 1000.0 / frameDuration;
        _fpsHistory.add(_currentFPS);

        if (_fpsHistory.length > 60) {
          // Keep last 60 frames
          _fpsHistory.removeAt(0);
        }

        _updateFPSStats();
      }
    }

    _lastFrameTime = now;
    _frameCount++;
  }

  void _updateFPSStats() {
    if (_fpsHistory.isEmpty) return;

    _averageFPS = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
    _minFPS = _fpsHistory.reduce((a, b) => a < b ? a : b);
    _maxFPS = _fpsHistory.reduce((a, b) => a > b ? a : b);
  }

  Future<void> _collectMetrics() async {
    if (!_isMonitoring) return;

    // Update native metrics first
    await _updateNativeMetrics();

    final memoryData = _createMemoryData();
    final fpsData = _createFPSData();
    final performanceMetrics = _createPerformanceMetrics();

    if (_isMonitoring && !_memoryController.isClosed) {
      try {
        _memoryController.add(memoryData);
        _fpsController.add(fpsData);
        _metricsController.add(performanceMetrics);
      } catch (_) {
        // Stream is closed, ignore
      }
    }
  }

  Future<void> _updateNativeMetrics() async {
    if (!_isMonitoring) return;

    // Skip native calls on web platform
    if (kIsWeb) {
      // On web, use FPS-based CPU estimation
      _currentCpuUsage = _estimateCPUUsage();
      return;
    }

    try {
      // Get memory info from native
      final memoryResult = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getMemoryInfo',
      );
      if (memoryResult != null) {
        _totalMemory = memoryResult['totalMemory'] as int? ?? _totalMemory;
        _availableMemory =
            memoryResult['availableMemory'] as int? ?? _availableMemory;
      }

      // Get CPU info from native
      final cpuResult = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getCpuUsage',
      );
      if (cpuResult != null) {
        _currentCpuUsage =
            (cpuResult['totalUsage'] as num?)?.toDouble() ?? _currentCpuUsage;
        final perCoreList = cpuResult['perCoreUsage'] as List?;
        if (perCoreList != null) {
          _perCoreCpuUsage = perCoreList
              .map((e) => (e as num).toDouble())
              .toList();
        }
      }
    } catch (e) {
      // Silently fallback to FPS-based CPU estimation if native fails
      // Only log in debug mode if it's not a MissingPluginException (expected on web)
      if (kDebugMode && !e.toString().contains('MissingPluginException')) {
        debugPrint('Error getting native metrics: $e');
      }
      // Fallback to FPS-based CPU estimation if native fails
      _currentCpuUsage = _estimateCPUUsage();
    }
  }

  FPSData _createFPSData() {
    return FPSData(
      currentFPS: _currentFPS,
      averageFPS: _averageFPS,
      minFPS: _minFPS == double.infinity ? 0.0 : _minFPS,
      maxFPS: _maxFPS,
      timestamp: DateTime.now(),
      frameCount: _frameCount,
    );
  }

  MemoryData _createMemoryData() {
    final currentUsage = _getCurrentMemoryUsage();
    if (currentUsage > _peakMemoryUsage) {
      _peakMemoryUsage = currentUsage;
    }

    return MemoryData(
      currentUsage: currentUsage,
      peakUsage: _peakMemoryUsage,
      availableMemory: _getAvailableMemory(),
      totalMemory: _totalMemory,
      usagePercentage: _totalMemory > 0
          ? (currentUsage / _totalMemory) * 100
          : 0.0,
      timestamp: DateTime.now(),
    );
  }

  PerformanceMetrics _createPerformanceMetrics() {
    // On web, always recalculate CPU usage based on current FPS
    // On native platforms, use the cached value from native if available
    final cpuUsage = kIsWeb
        ? _estimateCPUUsage() // Always recalculate on web
        : (_currentCpuUsage > 0
              ? _currentCpuUsage.clamp(0.0, 100.0)
              : _estimateCPUUsage());

    return PerformanceMetrics(
      fps: _currentFPS,
      memoryUsage: _getCurrentMemoryUsage(),
      timestamp: DateTime.now(),
      frameTime: _lastFrameTime != null
          ? DateTime.now().difference(_lastFrameTime!).inMicroseconds / 1000.0
          : 0.0,
      cpuUsage: cpuUsage,
    );
  }

  int _getCurrentMemoryUsage() {
    // On web, try to use browser's performance.memory API
    if (kIsWeb) {
      return _getWebMemoryUsage();
    }

    // Use dart:io ProcessInfo to get real RSS memory usage
    try {
      return ProcessInfo.currentRss;
    } catch (e) {
      // Silently return 0 on error (e.g., if ProcessInfo is not available)
      return 0;
    }
  }

  int _getWebMemoryUsage() {
    if (!kIsWeb) return 0;

    // Try to access performance.memory (available in Chrome/Chromium browsers)
    try {
      // Use JavaScript eval to access window.performance.memory.usedJSHeapSize
      // This is the most reliable way to access non-standard JavaScript APIs
      final result = js.context.callMethod('eval', [
        'window.performance && window.performance.memory && window.performance.memory.usedJSHeapSize || null',
      ]);

      if (result != null) {
        final memoryBytes = (result as num).toInt();
        if (memoryBytes > 0) {
          if (kDebugMode) {
            debugPrint(
              'Web memory: ${(memoryBytes / 1024 / 1024).toStringAsFixed(2)} MB',
            );
          }
          return memoryBytes;
        }
      }
    } catch (e) {
      // performance.memory is not available (e.g., in Firefox, Safari, or disabled)
      // This is expected and not an error - silently return 0
      if (kDebugMode && !_hasLoggedMemoryWarning) {
        _hasLoggedMemoryWarning = true;
        debugPrint('Web memory API not available: $e');
      }
    }
    return 0;
  }

  int _getAvailableMemory() {
    // Return native available memory if available
    return _availableMemory;
  }

  double _estimateCPUUsage() {
    // On web, always recalculate based on FPS (don't use cached value)
    // On native platforms, use cached value if available
    if (!kIsWeb && _currentCpuUsage > 0) {
      return _currentCpuUsage.clamp(0.0, 100.0);
    }

    // Fallback: Calculate CPU usage based on actual frame rendering efficiency
    // Lower FPS means higher CPU usage
    // At 60 FPS, CPU usage is low (around 30%)
    // At 30 FPS, CPU usage is high (around 60%)
    // At lower FPS, CPU usage approaches 100%

    // Use average FPS if current FPS is not available yet
    final fps = _currentFPS > 0 ? _currentFPS : _averageFPS;
    if (fps <= 0) return 0.0;

    // Calculate CPU usage as percentage of target FPS (60)
    // If FPS is 60, CPU usage is base usage (30%)
    // If FPS drops, CPU usage increases proportionally
    const targetFPS = 60.0;
    const baseCPUUsage = 30.0; // Base CPU usage at 60 FPS

    // Calculate how much we're struggling compared to target FPS
    final fpsRatio = fps / targetFPS;

    // CPU usage increases as FPS drops
    // Formula: base + (1 - fpsRatio) * (100 - base)
    final cpuUsage = baseCPUUsage + (1.0 - fpsRatio) * (100.0 - baseCPUUsage);

    return cpuUsage.clamp(0.0, 100.0);
  }
}
