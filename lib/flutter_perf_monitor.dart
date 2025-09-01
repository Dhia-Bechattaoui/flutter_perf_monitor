library flutter_perf_monitor;

/// Flutter Performance Monitor
///
/// A comprehensive performance monitoring package for Flutter applications
/// that provides real-time FPS tracking, memory usage monitoring, and CPU
/// usage statistics across multiple platforms.
///
/// ## Features
///
/// - 🎯 **Real-time FPS tracking** - Monitor frame rates in real-time
/// - 💾 **Memory usage monitoring** - Track memory consumption patterns
/// - 📊 **Performance metrics** - Comprehensive performance analytics
/// - 🔄 **Live updates** - Real-time performance data updates
/// - 📱 **Cross-platform** - Works on iOS, Android, Windows, macOS, Linux, and Web
/// - ⚡ **Lightweight** - Minimal performance impact on your app
///
/// ## Getting Started
///
/// ```dart
/// import 'package:flutter_perf_monitor/flutter_perf_monitor.dart';
///
/// void main() async {
///   // Initialize the performance monitor
///   await FlutterPerfMonitor.initialize();
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         body: Stack(
///           children: [
///             // Your app content
///             YourAppContent(),
///
///             // Performance monitor widget overlay
///             PerfMonitorWidget(
///               alignment: Alignment.topRight,
///               showFPS: true,
///               showMemory: true,
///               showCPU: true,
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```

export 'src/exceptions/perf_monitor_exceptions.dart';
export 'src/flutter_perf_monitor.dart';
export 'src/models/fps_data.dart';
export 'src/models/memory_data.dart';
export 'src/models/performance_metrics.dart';
export 'src/perf_monitor_widget.dart';
export 'src/platform/perf_monitor_interface.dart';
export 'src/utils/logger.dart';
