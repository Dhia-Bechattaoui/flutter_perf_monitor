# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-11-07

### Added
- **Web platform support**
  - Full web platform compatibility with proper error handling
  - CPU usage monitoring on web using FPS-based estimation
  - Graceful handling of missing native platform channels on web
  - Memory monitoring attempt on web (shows 0.0 MB due to browser security restrictions)

### Fixed
- **Web platform errors**
  - Fixed `MissingPluginException` errors when running on web
  - Added platform detection to skip native method channel calls on web
  - Fixed `ProcessInfo.currentRss` errors on web by using conditional imports
  - Updated `index.html` to use modern Flutter web initialization API
  - Fixed deprecated `FlutterLoader.loadEntrypoint` and `serviceWorkerVersion` warnings
  - Fixed `_flutter.buildConfig` requirement error
  - Fixed deprecated `apple-mobile-web-app-capable` meta tag
  - Replaced all `print` statements with `debugPrint` for better production code practices

### Changed
- **Web platform behavior**
  - CPU usage on web now dynamically updates based on FPS (no longer stuck at first value)
  - Memory shows 0.0 MB on web (expected limitation - browsers don't expose process memory)
  - Improved error handling with silent fallbacks for web platform
  - Added conditional imports for `dart:io` and `dart:js` to prevent compilation errors on different platforms

### Technical Details
- **Web Implementation**: Conditional platform detection using `kIsWeb`
  - Uses `dart:js` for JavaScript interop to access `performance.memory` API
  - Falls back gracefully when browser APIs are unavailable
  - CPU estimation based on FPS performance (60 FPS = ~30% CPU, lower FPS = higher CPU)

## [0.1.1] - 2025-11-04

### Fixed
- **Android CPU usage calculation accuracy**
  - Fixed CPU usage calculation to use proper two-snapshot comparison method
  - Previously used instantaneous snapshot which didn't reflect actual CPU usage over time
  - Now correctly calculates CPU usage percentage by comparing differences between `/proc/stat` readings
  - First call returns 0.0% (baseline initialization), subsequent calls show accurate CPU usage

## [0.1.0] - 2024-11-03

### Added
- **Native implementations for Android and iOS**
  - Real system-level memory metrics (total, available, used) via platform channels
  - Accurate CPU usage monitoring with per-core support on Android and iOS
  - Android: CPU metrics via `/proc/stat` with graceful fallback for restricted devices
  - iOS: CPU metrics via `task_threads` and memory via `mach_task_basic_info`
- **Enhanced platform channel integration**
  - `getMemoryInfo` method returning comprehensive memory statistics
  - `getCpuUsage` method returning total and per-core CPU percentages
  - Fallback mechanisms for platforms without native support
- **Documentation improvements**
  - Added `SETUP.md` with detailed native implementation documentation
  - Updated `README.md` with native capabilities and fallback behavior
  - Documented platform-specific APIs and limitations
- **Build system enhancements**
  - Java/Kotlin 17 toolchain configuration for Android
  - Modern Gradle configuration with Kotlin DSL
  - Proper `.gitignore` configuration for generated files
  - iOS project structure regeneration for example app

### Changed
- **Memory monitoring accuracy**
  - Now shows real system total/available memory on Android/iOS
  - Conditionally displays "Available" and "Usage" only when native data available
  - Removed "N/A" placeholders for better UX
- **CPU monitoring accuracy**
  - Real system CPU usage on Android and iOS (not FPS-based)
  - Per-core CPU usage tracking on supported platforms
  - Improved FPS-based fallback for non-native platforms
- **Platform channel communication**
  - Made `_collectMetrics` async for native metric updates
  - Added error handling with debug logging
  - Graceful degradation when native calls fail

### Fixed
- Android build errors with JVM compatibility (Java 17 configuration)
- Permission denied errors on Android 8+ devices accessing `/proc/stat`
- iOS missing `Runner.xcodeproj` causing build failures
- CPU usage showing 0.0% on first frame calculation
- Example app test failures with boilerplate counter test

### Technical Details
- **Android Implementation**: `FlutterPerfMonitorPlugin.kt` (156 lines)
  - Uses `ActivityManager.MemoryInfo` for memory metrics
  - Reads `/proc/stat` with permission handling
  - Fallback to memory-pressure-based CPU estimation
- **iOS Implementation**: `FlutterPerfMonitorPlugin.swift` (127 lines)
  - Uses `ProcessInfo.physicalMemory` and `mach_task_basic_info`
  - Thread-based CPU monitoring via `task_threads`
  - Proper memory management with `vm_deallocate`
- **Platform Channel**: `flutter_perf_monitor` channel with two methods
  - All native calls wrapped in try-catch with fallbacks
  - Non-blocking async updates every 100ms

## [0.0.1] - 2024-01-01

### Added
- Initial release
- Project structure and configuration
- Basic Flutter performance monitoring package setup
- FPS tracking capabilities foundation
- Memory usage monitoring foundation
- Real-time performance monitoring architecture

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

## Version History

- **0.2.0** - Added web platform support with proper error handling and CPU monitoring
- **0.1.1** - Fixed Android CPU usage calculation to use proper two-snapshot comparison method
- **0.1.0** - Added native Android/iOS implementations for real CPU and memory metrics
- **0.0.1** - Initial release with basic project structure and performance monitoring foundation

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
