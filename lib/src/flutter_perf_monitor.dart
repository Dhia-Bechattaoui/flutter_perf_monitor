import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'exceptions/perf_monitor_exceptions.dart';
import 'models/fps_data.dart';
import 'models/memory_data.dart';
import 'models/performance_metrics.dart';
import 'platform/perf_monitor_factory.dart';
import 'utils/logger.dart';

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
    try {
      if (instance._isInitialized) {
        PerfMonitorLogger.warning('FlutterPerfMonitor is already initialized');
        return;
      }

      instance._isInitialized = true;

      // Set up frame callback for FPS monitoring
      SchedulerBinding.instance.addPersistentFrameCallback((
        Duration timeStamp,
      ) {
        instance._onFrame(timeStamp);
      });

      // Initialize platform metrics
      instance._updatePlatformMetrics();

      PerfMonitorLogger.info('FlutterPerfMonitor initialized successfully');
    } catch (e, stackTrace) {
      PerfMonitorLogger.error(
        'Failed to initialize FlutterPerfMonitor',
        e,
        stackTrace,
      );
      instance._isInitialized = false;
      rethrow;
    }
  }

  /// Start performance monitoring
  ///
  /// Begins collecting performance metrics at regular intervals.
  /// The monitoring frequency can be adjusted by changing the [interval] parameter.
  static void startMonitoring({
    Duration interval = const Duration(milliseconds: 100),
  }) {
    try {
      if (!instance._isInitialized) {
        throw const PerfMonitorNotInitializedException();
      }

      if (instance._isMonitoring) {
        PerfMonitorLogger.warning('Performance monitoring is already running');
        return;
      }

      if (interval.inMilliseconds < 16) {
        throw const InvalidConfigurationException(
          'Monitoring interval cannot be less than 16ms (60 FPS)',
          code: 'INVALID_INTERVAL',
        );
      }

      instance._isMonitoring = true;
      instance._monitoringTimer = Timer.periodic(interval, (timer) {
        try {
          instance._collectMetrics();
        } catch (e, stackTrace) {
          PerfMonitorLogger.error('Error collecting metrics', e, stackTrace);
        }
      });

      PerfMonitorLogger.info(
        'Performance monitoring started with interval: ${interval.inMilliseconds}ms',
      );
    } catch (e) {
      PerfMonitorLogger.error('Failed to start performance monitoring', e);
      rethrow;
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
      print('Performance monitoring stopped');
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

  void _collectMetrics() {
    // Update platform metrics before creating data objects
    _updatePlatformMetrics();

    final memoryData = _createMemoryData();
    final fpsData = _createFPSData();
    final performanceMetrics = _createPerformanceMetrics();

    _memoryController.add(memoryData);
    _fpsController.add(fpsData);
    _metricsController.add(performanceMetrics);
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
    return PerformanceMetrics(
      fps: _currentFPS,
      memoryUsage: _getCurrentMemoryUsage(),
      timestamp: DateTime.now(),
      frameTime: _lastFrameTime != null
          ? DateTime.now().difference(_lastFrameTime!).inMicroseconds / 1000.0
          : 0.0,
      cpuUsage: _currentCPUUsage,
    );
  }

  int _getCurrentMemoryUsage() {
    // Use platform-specific implementation for real memory monitoring
    return _currentMemoryUsage;
  }

  int _getAvailableMemory() {
    return _availableMemory;
  }

  int _currentMemoryUsage = 0;
  int _availableMemory = 0;
  int _totalMemory = 0;
  double _currentCPUUsage = 0.0;

  void _updatePlatformMetrics() async {
    try {
      final perfMonitor = PerfMonitorFactory.instance;
      _currentMemoryUsage = await perfMonitor.getMemoryUsage();
      _totalMemory = await perfMonitor.getTotalMemory();
      _availableMemory = await perfMonitor.getAvailableMemory();
      _currentCPUUsage = await perfMonitor.getCPUUsage();

      PerfMonitorLogger.logMetrics(
        fps: _currentFPS,
        memoryUsage: _currentMemoryUsage,
        cpuUsage: _currentCPUUsage,
        frameTime: _lastFrameTime != null
            ? DateTime.now().difference(_lastFrameTime!).inMicroseconds / 1000.0
            : 0.0,
      );
    } catch (e, stackTrace) {
      PerfMonitorLogger.error('Error updating platform metrics', e, stackTrace);
      // Fallback to previous values if platform calls fail
    }
  }
}
