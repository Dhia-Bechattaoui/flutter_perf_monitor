# Native Implementation Setup

This package now includes native implementations for Android and iOS to provide accurate CPU and memory metrics.

## Platform Support

### Android
- **File**: `android/src/main/kotlin/com/github/dhia_bechattaoui/flutter_perf_monitor/FlutterPerfMonitorPlugin.kt`
- **Features**:
  - Total memory via `ActivityManager.MemoryInfo`
  - Available memory via `ActivityManager.MemoryInfo`
  - Per-core CPU usage via `/proc/stat`
  - Total CPU usage (average of all cores)

### iOS
- **File**: `ios/Classes/FlutterPerfMonitorPlugin.swift`
- **Features**:
  - Total memory via `ProcessInfo.physicalMemory`
  - Used memory via `mach_task_basic_info`
  - Available memory (calculated)
  - Per-core CPU usage via `task_threads`
  - Total CPU usage (sum of all threads)

## How It Works

The Flutter package communicates with native code via platform channels:

### Platform Channel Name
`flutter_perf_monitor`

### Methods

#### `getMemoryInfo`
Returns memory information:
```dart
{
  "totalMemory": int,      // Total system memory in bytes
  "availableMemory": int,  // Available memory in bytes
  "usedMemory": int,       // Used memory in bytes
  "percentUsed": double    // Usage percentage (0-100)
}
```

#### `getCpuUsage`
Returns CPU usage information:
```dart
{
  "totalUsage": double,        // Total CPU usage percentage
  "perCoreUsage": List<double> // Per-core CPU usage percentages
}
```

## Integration

The platform channels are automatically registered when you include this package in your Flutter app. No additional setup is required.

### Fallback Behavior

If native metrics are unavailable, the package falls back to:
- **Web (JS)**: Uses `window.performance.memory.usedJSHeapSize` when the browser exposes it (generally Chrome/Edge). Safari/Firefox return `null`, so memory becomes `0`.
- **Web (WASM)**: Browsers keep wasm isolates sandboxed from JavaScript, so memory usage always reports `0`.
- **Desktop (macOS, Windows, Linux)**: Process-level memory via `ProcessInfo.currentRss`
- **CPU**: FPS-based estimation

## Building

The native code is automatically compiled when you build your Flutter app for Android or iOS:

```bash
flutter build apk          # Android
flutter build ios          # iOS
```

## Android Configuration

No additional configuration required. The plugin uses standard Android APIs available in API 21+.

## iOS Configuration

No additional configuration required. The plugin uses standard iOS APIs available in iOS 11+.

## Troubleshooting

### Android

If you encounter permission issues:
- Ensure your app has the necessary permissions in `AndroidManifest.xml`
- Note: The `/proc/stat` file is typically accessible without special permissions

### iOS

If CPU metrics are not available:
- The app must be running on a physical device for accurate thread count
- Simulator may report different metrics

## Development

To modify the native implementations:

1. **Android**: Edit `FlutterPerfMonitorPlugin.kt`
2. **iOS**: Edit `FlutterPerfMonitorPlugin.swift`
3. Rebuild your app: `flutter clean && flutter pub get && flutter run`

## License

The native implementations are licensed under the same MIT license as the Flutter package.

