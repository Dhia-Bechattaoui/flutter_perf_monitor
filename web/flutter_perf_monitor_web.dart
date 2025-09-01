import 'package:flutter_perf_monitor/src/platform/web_perf_monitor.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web plugin registration for Flutter Performance Monitor.
class FlutterPerfMonitorWeb {
  /// Registers the web plugin.
  static void registerWith(Registrar registrar) {
    // Initialize web-specific performance monitoring
    WebPerfMonitor();
  }
}
