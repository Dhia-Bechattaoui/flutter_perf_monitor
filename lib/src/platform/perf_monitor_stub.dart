import 'perf_monitor_interface.dart';

/// Stub implementation for performance monitoring.
/// This is used as a fallback when platform-specific implementations are not available.
class PerfMonitorStub implements PerfMonitorInterface {
  /// Gets the current memory usage in bytes.
  @override
  Future<int> getMemoryUsage() async {
    // Return a placeholder value
    return 1024 * 1024; // 1MB
  }

  /// Gets the current CPU usage percentage.
  @override
  Future<double> getCPUUsage() async {
    // Return a placeholder value
    return 0.0;
  }

  /// Gets the total available memory in bytes.
  @override
  Future<int> getTotalMemory() async {
    // Return a placeholder value
    return 4 * 1024 * 1024 * 1024; // 4GB
  }

  /// Gets the available memory in bytes.
  @override
  Future<int> getAvailableMemory() async {
    final total = await getTotalMemory();
    final used = await getMemoryUsage();
    return total - used;
  }
}
