# Flutter Performance Monitor

[![Pub Version](https://img.shields.io/pub/v/flutter_perf_monitor.svg)](https://pub.dev/packages/flutter_perf_monitor)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)

A lightweight package to track real-time performance metrics in your Flutter applications, including FPS and system-level memory and CPU usage.

<img src="assets/example.gif" width="300" alt="Flutter Performance Monitor Example">

## Key Features

- Real-time FPS tracking.
- Memory and CPU usage monitoring with native implementations for iOS and Android.
- Live metric updates with minimal performance impact.
- Cross-platform support (iOS, Android, Web, and Desktop).

## Getting Started

Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_perf_monitor: ^0.2.1
```

### Basic Usage

Initialize the monitor and add the widget to your widget tree:

```dart
import 'package:flutter_perf_monitor/flutter_perf_monitor.dart';

void main() {
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
            PerfMonitorWidget(),
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

The primary interface is `FlutterPerfMonitor`, which exposes the following methods:

- `initialize()`: Sets up the performance monitor.
- `startMonitoring()` / `stopMonitoring()`: Controls the monitoring lifecycle.
- `getFPS()`: Returns the current frame rate.
- `getMemoryUsage()`: Returns total, available, and used memory.
- `getPerCoreCpuUsage()`: Returns CPU usage percentages.

For displaying metrics, use the `PerfMonitorWidget`.

## Platform Specifics

We provide native integrations for accurate hardware metrics where possible, and fallback mechanisms for others.

### Native Support (Android & iOS)

- **Android**: CPU usage is read from `/proc/stat`. Memory is fetched via `ActivityManager.MemoryInfo`.
- **iOS**: CPU usage leverages `task_threads`. Memory is fetched via `ProcessInfo` and `mach_task_basic_info`.

### Fallback Behavior

When native metrics are unavailable, the package uses fallbacks:

- **Desktop**: Process memory via `ProcessInfo.currentRss`. CPU relies on FPS-based estimation.
- **Web (JS)**: Uses `window.performance.memory.usedJSHeapSize` when the browser allows it (e.g., Chrome/Edge). Otherwise, defaults to 0.
- **Web (WASM)**: Wasm sandbox restrictions prevent direct heap access, so memory is reported as 0. FPS tracking remains active.

For more details on implementation, please refer to [SETUP.md](SETUP.md).

## Contributing & Support

We welcome contributions. Please review [CONTRIBUTING.md](CONTRIBUTING.md) for our guidelines. 

If you encounter issues or have feedback, feel free to open an issue on our [GitHub repository](https://github.com/Dhia-Bechattaoui/flutter_perf_monitor/issues).

See [CHANGELOG.md](CHANGELOG.md) for version history.

License: [MIT](LICENSE)
