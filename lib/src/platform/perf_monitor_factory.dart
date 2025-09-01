// Conditional imports
import 'perf_monitor_impl.dart'
    if (dart.library.io) 'method_channel_perf_monitor.dart'
    if (dart.library.html) 'web_perf_monitor.dart';
import 'perf_monitor_interface.dart';
import 'perf_monitor_stub.dart';

/// Factory class for creating platform-specific performance monitor implementations.
class PerfMonitorFactory {
  static PerfMonitorInterface? _instance;

  /// Gets the appropriate performance monitor implementation for the current platform.
  static PerfMonitorInterface get instance {
    _instance ??= _createInstance();
    return _instance!;
  }

  /// Creates a new instance based on the current platform.
  static PerfMonitorInterface _createInstance() {
    try {
      // Try to create the appropriate implementation
      return perfMonitorImpl();
    } catch (e) {
      // Fallback to stub implementation
      return PerfMonitorStub();
    }
  }

  /// Resets the singleton instance (useful for testing).
  static void reset() {
    _instance = null;
  }
}
