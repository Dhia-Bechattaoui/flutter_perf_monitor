# Flutter Performance Monitor

[![Pub Version](https://img.shields.io/pub/v/flutter_perf_monitor.svg)](https://pub.dev/packages/flutter_perf_monitor)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)

A comprehensive performance monitoring package for Flutter applications that provides real-time FPS tracking, memory usage monitoring, and CPU usage statistics across all platforms.

## Features

- 🎯 **Real-time FPS tracking** - Monitor frame rates in real-time
- 💾 **Real memory monitoring** - Track actual memory consumption using platform APIs
- 🖥️ **Real CPU monitoring** - Monitor actual CPU usage with native implementations
- 📊 **Performance metrics** - Comprehensive performance analytics
- 🔄 **Live updates** - Real-time performance data updates
- 📱 **Universal platform support** - Works on iOS, Android, Web, Windows, macOS, and Linux
- ⚡ **WASM compatible** - Future-proof for Flutter Web improvements
- 🏆 **Perfect quality score** - 160/160 Pana score for pub.dev
- ⚡ **Lightweight** - Minimal performance impact on your app

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_perf_monitor: ^0.0.2
```

### Usage

```dart
import 'package:flutter_perf_monitor/flutter_perf_monitor.dart';

void main() async {
  // Initialize the performance monitor
  await FlutterPerfMonitor.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Your app content
            YourAppContent(),
            
            // Performance monitor widget overlay
            PerfMonitorWidget(
              alignment: Alignment.topRight,
              showFPS: true,
              showMemory: true,
              showCPU: true,
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
- `getCPUUsage()` - Get current CPU usage
- `getTotalMemory()` - Get total available memory
- `getAvailableMemory()` - Get available memory

### PerfMonitorWidget

A widget that displays performance metrics.

## Platform Support

This package provides **universal platform support** with native implementations:

- **✅ iOS** - Native mach APIs for real memory and CPU monitoring
- **✅ Android** - ActivityManager integration for system metrics
- **✅ Web** - Browser APIs with intelligent fallbacks
- **✅ Windows** - PDH and Process APIs for system monitoring
- **✅ macOS** - Native mach APIs for performance metrics
- **✅ Linux** - /proc filesystem integration
- **✅ WASM** - Compatible with Flutter Web WASM runtime

## Quality Score

This package has achieved a **perfect 160/160 Pana score** on pub.dev, ensuring:
- ✅ Zero linting issues
- ✅ Perfect code formatting
- ✅ Comprehensive documentation
- ✅ Universal platform support
- ✅ Modern Flutter/Dart compatibility

## Example

See the [example](example/) directory for a complete working example.

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
