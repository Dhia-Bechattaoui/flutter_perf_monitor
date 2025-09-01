import 'dart:async';

/// Abstract interface for platform-specific performance monitoring implementations.
abstract class PerfMonitorInterface {
  /// Gets the current memory usage in bytes.
  Future<int> getMemoryUsage();

  /// Gets the current CPU usage percentage.
  Future<double> getCPUUsage();

  /// Gets the total available memory in bytes.
  Future<int> getTotalMemory();

  /// Gets the available memory in bytes.
  Future<int> getAvailableMemory();
}
