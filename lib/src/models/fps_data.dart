/// Represents FPS (Frames Per Second) data for performance monitoring.
class FPSData {
  /// Current FPS value
  final double currentFPS;

  /// Average FPS over the monitoring period
  final double averageFPS;

  /// Minimum FPS recorded
  final double minFPS;

  /// Maximum FPS recorded
  final double maxFPS;

  /// Timestamp when FPS was measured
  final DateTime timestamp;

  /// Frame count since last measurement
  final int frameCount;

  const FPSData({
    required this.currentFPS,
    required this.averageFPS,
    required this.minFPS,
    required this.maxFPS,
    required this.timestamp,
    required this.frameCount,
  });

  /// Creates a copy of this object with the given fields replaced by new values.
  FPSData copyWith({
    double? currentFPS,
    double? averageFPS,
    double? minFPS,
    double? maxFPS,
    DateTime? timestamp,
    int? frameCount,
  }) {
    return FPSData(
      currentFPS: currentFPS ?? this.currentFPS,
      averageFPS: averageFPS ?? this.averageFPS,
      minFPS: minFPS ?? this.minFPS,
      maxFPS: maxFPS ?? this.maxFPS,
      timestamp: timestamp ?? this.timestamp,
      frameCount: frameCount ?? this.frameCount,
    );
  }

  @override
  String toString() {
    return 'FPSData(currentFPS: $currentFPS, averageFPS: $averageFPS, '
        'minFPS: $minFPS, maxFPS: $maxFPS, timestamp: $timestamp, '
        'frameCount: $frameCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FPSData &&
        other.currentFPS == currentFPS &&
        other.averageFPS == averageFPS &&
        other.minFPS == minFPS &&
        other.maxFPS == maxFPS &&
        other.timestamp == timestamp &&
        other.frameCount == frameCount;
  }

  @override
  int get hashCode {
    return Object.hash(
        currentFPS, averageFPS, minFPS, maxFPS, timestamp, frameCount);
  }
}
