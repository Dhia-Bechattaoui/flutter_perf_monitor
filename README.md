# Flutter Performance Monitor

[![Pub Version](https://img.shields.io/pub/v/flutter_perf_monitor.svg)](https://pub.dev/packages/flutter_perf_monitor)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)

Real-time performance monitoring with FPS tracking and memory usage for Flutter applications.

<img src="assets/example.gif" width="300" alt="Flutter Performance Monitor Example">

## Features

- 🎯 **Real-time FPS tracking** - Monitor frame rates in real-time
- 💾 **Memory usage monitoring** - Track memory consumption patterns
- 📊 **Performance metrics** - Comprehensive performance analytics
- 🔄 **Live updates** - Real-time performance data updates
- 📱 **Cross-platform** - Works on iOS, Android, Web, and Desktop
- ⚡ **Lightweight** - Minimal performance impact on your app
- 🚀 **Native implementations** - Real CPU and memory metrics on Android/iOS

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_perf_monitor: ^0.1.0
```

### Usage

```dart
import 'package:flutter_perf_monitor/flutter_perf_monitor.dart';

void main() {
  // Initialize the performance monitor
  FlutterPerfMonitor.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // Performance monitor widget
            PerfMonitorWidget(),
            
            // Your app content
            Expanded(
              child: YourAppContent(),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### FlutterPerfMonitor

The main class for performance monitoring.

#### Methods

- `initialize()` - Initialize the performance monitor
- `startMonitoring()` - Start performance monitoring
- `stopMonitoring()` - Stop performance monitoring
- `getFPS()` - Get current FPS value
- `getMemoryUsage()` - Get current memory usage
- `getPerCoreCpuUsage()` - Get per-core CPU usage percentages

### PerfMonitorWidget

A widget that displays performance metrics.

## Example

See the [example](example/) directory for a complete working example.

## Native Implementations

This package includes native implementations for Android and iOS to provide accurate system-level metrics:

### Android
- **Total & Available Memory**: Via `ActivityManager.MemoryInfo`
- **Per-Core CPU Usage**: Via `/proc/stat`
- **Total CPU Usage**: Average of all cores

### iOS
- **Total & Available Memory**: Via `ProcessInfo` and `mach_task_basic_info`
- **Per-Core CPU Usage**: Via `task_threads`
- **Total CPU Usage**: Sum of all thread usage

### Fallback Behavior

On platforms without native support (Web, Desktop), the package falls back to:
- **Memory**: Process-level memory via `ProcessInfo.currentRss`
- **CPU**: FPS-based estimation

For detailed implementation information, see [SETUP.md](SETUP.md).

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any problems or have suggestions, please file an issue at the [GitHub repository](https://github.com/Dhia-Bechattaoui/flutter_perf_monitor/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
