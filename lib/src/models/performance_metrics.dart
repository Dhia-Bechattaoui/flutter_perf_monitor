/// Represents overall performance metrics for a Flutter application.
class PerformanceMetrics {
  /// Creates a new PerformanceMetrics instance.
  ///
  /// [fps] - Current FPS value
  /// [memoryUsage] - Current memory usage in bytes
  /// [timestamp] - Timestamp when metrics were collected
  /// [frameTime] - Frame rendering time in milliseconds
  /// [cpuUsage] - CPU usage percentage
  const PerformanceMetrics({
    required this.fps,
    required this.memoryUsage,
    required this.timestamp,
    required this.frameTime,
    required this.cpuUsage,
  });

  /// Current FPS value
  final double fps;

  /// Current memory usage in bytes
  final int memoryUsage;

  /// Timestamp when metrics were collected
  final DateTime timestamp;

  /// Frame rendering time in milliseconds
  final double frameTime;

  /// CPU usage percentage
  final double cpuUsage;

  /// Creates a copy of this object with the given fields replaced by new values.
  PerformanceMetrics copyWith({
    double? fps,
    int? memoryUsage,
    DateTime? timestamp,
    double? frameTime,
    double? cpuUsage,
  }) {
    return PerformanceMetrics(
      fps: fps ?? this.fps,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      timestamp: timestamp ?? this.timestamp,
      frameTime: frameTime ?? this.frameTime,
      cpuUsage: cpuUsage ?? this.cpuUsage,
    );
  }

  @override
  String toString() {
    return 'PerformanceMetrics(fps: $fps, memoryUsage: $memoryUsage, '
        'timestamp: $timestamp, frameTime: $frameTime, cpuUsage: $cpuUsage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceMetrics &&
        other.fps == fps &&
        other.memoryUsage == memoryUsage &&
        other.timestamp == timestamp &&
        other.frameTime == frameTime &&
        other.cpuUsage == cpuUsage;
  }

  @override
  int get hashCode {
    return Object.hash(fps, memoryUsage, timestamp, frameTime, cpuUsage);
  }
}
