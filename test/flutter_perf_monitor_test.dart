import 'package:flutter_perf_monitor/flutter_perf_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FlutterPerfMonitor', () {
    setUp(() {
      // Reset the singleton instance before each test
      FlutterPerfMonitor.dispose();
    });

    tearDown(() {
      FlutterPerfMonitor.dispose();
    });

    test('should initialize successfully', () async {
      await FlutterPerfMonitor.initialize();
      // No exception should be thrown
    });

    test('should not allow monitoring before initialization', () {
      expect(
        () => FlutterPerfMonitor.startMonitoring(),
        throwsStateError,
      );
    });

    test('should start and stop monitoring after initialization', () async {
      await FlutterPerfMonitor.initialize();

      FlutterPerfMonitor.startMonitoring();
      // No exception should be thrown

      FlutterPerfMonitor.stopMonitoring();
      // No exception should be thrown
    });

    test('should provide metrics stream', () async {
      await FlutterPerfMonitor.initialize();

      final metricsStream = FlutterPerfMonitor.instance.metricsStream;
      expect(metricsStream, isNotNull);
    });

    test('should provide FPS stream', () async {
      await FlutterPerfMonitor.initialize();

      final fpsStream = FlutterPerfMonitor.instance.fpsStream;
      expect(fpsStream, isNotNull);
    });

    test('should provide memory stream', () async {
      await FlutterPerfMonitor.initialize();

      final memoryStream = FlutterPerfMonitor.instance.memoryStream;
      expect(memoryStream, isNotNull);
    });

    test('should get current FPS', () async {
      await FlutterPerfMonitor.initialize();

      final fps = FlutterPerfMonitor.getFPS();
      expect(fps, isA<double>());
      expect(fps, greaterThanOrEqualTo(0.0));
    });

    test('should get current memory usage', () async {
      await FlutterPerfMonitor.initialize();

      final memoryUsage = FlutterPerfMonitor.getMemoryUsage();
      expect(memoryUsage, isA<int>());
      expect(memoryUsage, greaterThanOrEqualTo(0));
    });

    test('should get current metrics', () async {
      await FlutterPerfMonitor.initialize();

      final metrics = FlutterPerfMonitor.getCurrentMetrics();
      expect(metrics, isA<PerformanceMetrics>());
      expect(metrics.fps, isA<double>());
      expect(metrics.memoryUsage, isA<int>());
      expect(metrics.timestamp, isA<DateTime>());
      expect(metrics.frameTime, isA<double>());
      expect(metrics.cpuUsage, isA<double>());
    });

    test('should handle multiple dispose calls gracefully', () async {
      await FlutterPerfMonitor.initialize();

      FlutterPerfMonitor.dispose();
      FlutterPerfMonitor.dispose(); // Should not throw
    });
  });

  group('PerformanceMetrics', () {
    test('should create with required parameters', () {
      final now = DateTime.now();
      final metrics = PerformanceMetrics(
        fps: 60.0,
        memoryUsage: 1024 * 1024,
        timestamp: now,
        frameTime: 16.67,
        cpuUsage: 25.0,
      );

      expect(metrics.fps, equals(60.0));
      expect(metrics.memoryUsage, equals(1024 * 1024));
      expect(metrics.timestamp, equals(now));
      expect(metrics.frameTime, equals(16.67));
      expect(metrics.cpuUsage, equals(25.0));
    });

    test('should support copyWith', () {
      final now = DateTime.now();
      final original = PerformanceMetrics(
        fps: 60.0,
        memoryUsage: 1024 * 1024,
        timestamp: now,
        frameTime: 16.67,
        cpuUsage: 25.0,
      );

      final updated = original.copyWith(fps: 30.0);
      expect(updated.fps, equals(30.0));
      expect(updated.memoryUsage, equals(original.memoryUsage));
      expect(updated.timestamp, equals(original.timestamp));
      expect(updated.frameTime, equals(original.frameTime));
      expect(updated.cpuUsage, equals(original.cpuUsage));
    });

    test('should implement equality correctly', () {
      final now = DateTime.now();
      final metrics1 = PerformanceMetrics(
        fps: 60.0,
        memoryUsage: 1024 * 1024,
        timestamp: now,
        frameTime: 16.67,
        cpuUsage: 25.0,
      );

      final metrics2 = PerformanceMetrics(
        fps: 60.0,
        memoryUsage: 1024 * 1024,
        timestamp: now,
        frameTime: 16.67,
        cpuUsage: 25.0,
      );

      expect(metrics1, equals(metrics2));
      expect(metrics1.hashCode, equals(metrics2.hashCode));
    });

    test('should provide meaningful string representation', () {
      final now = DateTime.now();
      final metrics = PerformanceMetrics(
        fps: 60.0,
        memoryUsage: 1024 * 1024,
        timestamp: now,
        frameTime: 16.67,
        cpuUsage: 25.0,
      );

      final str = metrics.toString();
      expect(str, contains('60.0'));
      expect(str, contains('1048576'));
      expect(str, contains('16.67'));
      expect(str, contains('25.0'));
    });
  });

  group('FPSData', () {
    test('should create with required parameters', () {
      final now = DateTime.now();
      final fpsData = FPSData(
        currentFPS: 60.0,
        averageFPS: 58.5,
        minFPS: 45.0,
        maxFPS: 62.0,
        timestamp: now,
        frameCount: 1000,
      );

      expect(fpsData.currentFPS, equals(60.0));
      expect(fpsData.averageFPS, equals(58.5));
      expect(fpsData.minFPS, equals(45.0));
      expect(fpsData.maxFPS, equals(62.0));
      expect(fpsData.timestamp, equals(now));
      expect(fpsData.frameCount, equals(1000));
    });

    test('should support copyWith', () {
      final now = DateTime.now();
      final original = FPSData(
        currentFPS: 60.0,
        averageFPS: 58.5,
        minFPS: 45.0,
        maxFPS: 62.0,
        timestamp: now,
        frameCount: 1000,
      );

      final updated = original.copyWith(currentFPS: 30.0);
      expect(updated.currentFPS, equals(30.0));
      expect(updated.averageFPS, equals(original.averageFPS));
      expect(updated.minFPS, equals(original.minFPS));
      expect(updated.maxFPS, equals(original.maxFPS));
      expect(updated.timestamp, equals(original.timestamp));
      expect(updated.frameCount, equals(original.frameCount));
    });
  });

  group('MemoryData', () {
    test('should create with required parameters', () {
      final now = DateTime.now();
      final memoryData = MemoryData(
        currentUsage: 1024 * 1024,
        peakUsage: 2048 * 1024,
        availableMemory: 3072 * 1024,
        totalMemory: 4096 * 1024,
        usagePercentage: 25.0,
        timestamp: now,
      );

      expect(memoryData.currentUsage, equals(1024 * 1024));
      expect(memoryData.peakUsage, equals(2048 * 1024));
      expect(memoryData.availableMemory, equals(3072 * 1024));
      expect(memoryData.totalMemory, equals(4096 * 1024));
      expect(memoryData.usagePercentage, equals(25.0));
      expect(memoryData.timestamp, equals(now));
    });

    test('should convert bytes to megabytes correctly', () {
      final memoryData = MemoryData(
        currentUsage: 1024 * 1024,
        peakUsage: 2048 * 1024,
        availableMemory: 3072 * 1024,
        totalMemory: 4096 * 1024,
        usagePercentage: 25.0,
        timestamp: DateTime.now(),
      );

      expect(memoryData.currentUsageMB, equals(1.0));
      expect(memoryData.peakUsageMB, equals(2.0));
      expect(memoryData.availableMemoryMB, equals(3.0));
      expect(memoryData.totalMemoryMB, equals(4.0));
    });

    test('should provide meaningful string representation', () {
      final memoryData = MemoryData(
        currentUsage: 1024 * 1024,
        peakUsage: 2048 * 1024,
        availableMemory: 3072 * 1024,
        totalMemory: 4096 * 1024,
        usagePercentage: 25.0,
        timestamp: DateTime.now(),
      );

      final str = memoryData.toString();
      expect(str, contains('1.00MB'));
      expect(str, contains('2.00MB'));
      expect(str, contains('3.00MB'));
      expect(str, contains('4.00MB'));
      expect(str, contains('25.00%'));
    });
  });
}
