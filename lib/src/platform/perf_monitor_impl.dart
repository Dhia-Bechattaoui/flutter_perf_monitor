import 'perf_monitor_interface.dart';
import 'perf_monitor_stub.dart';

/// Default implementation that falls back to stub.
/// This file is used when no platform-specific implementation is available.
PerfMonitorInterface perfMonitorImpl() => PerfMonitorStub();
