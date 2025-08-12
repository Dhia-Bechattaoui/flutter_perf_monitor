# Flutter Performance Monitor Example

This directory contains an example Flutter application that demonstrates how to use the `flutter_perf_monitor` package.

## Getting Started

1. Make sure you have Flutter installed and set up
2. Navigate to this directory: `cd example`
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the example app

## What the Example Shows

The example app demonstrates:

- How to initialize the performance monitor
- How to start and stop monitoring
- How to display the performance monitor widget
- Real-time FPS, memory, and CPU monitoring
- Interactive performance monitoring controls

## Features Demonstrated

- **Performance Monitor Widget**: A customizable overlay widget showing real-time metrics
- **FPS Tracking**: Real-time frame rate monitoring
- **Memory Usage**: Current and peak memory consumption
- **CPU Usage**: Estimated CPU utilization
- **Interactive Controls**: Start/stop monitoring with a button
- **Visual Feedback**: Animated elements to generate load for testing

## Usage

1. Launch the app
2. Tap the "Start Monitoring" button to begin performance tracking
3. The performance monitor widget will appear in the top-left corner
4. Tap the widget to expand it and see detailed metrics
5. Tap "Stop Monitoring" to stop the performance tracking

## Customization

The example shows how to customize the performance monitor widget:

```dart
PerfMonitorWidget(
  alignment: Alignment.topLeft,
  backgroundColor: Color(0x80000000),
  textColor: Colors.white,
  showFPS: true,
  showMemory: true,
  showCPU: true,
)
```

## Troubleshooting

If you encounter any issues:

1. Make sure Flutter is properly installed
2. Run `flutter doctor` to check your setup
3. Ensure all dependencies are installed with `flutter pub get`
4. Check the console for any error messages

## Learn More

For more information about the package, see the main [README.md](../README.md) file.
