/// Represents memory usage data for performance monitoring.
class MemoryData {
  /// Creates a new MemoryData instance.
  ///
  /// [currentUsage] - Current memory usage in bytes
  /// [peakUsage] - Peak memory usage in bytes
  /// [availableMemory] - Available memory in bytes
  /// [totalMemory] - Total memory in bytes
  /// [usagePercentage] - Memory usage percentage
  /// [timestamp] - Timestamp when memory was measured
  const MemoryData({
    required this.currentUsage,
    required this.peakUsage,
    required this.availableMemory,
    required this.totalMemory,
    required this.usagePercentage,
    required this.timestamp,
  });

  /// Current memory usage in bytes
  final int currentUsage;

  /// Peak memory usage in bytes
  final int peakUsage;

  /// Available memory in bytes
  final int availableMemory;

  /// Total memory in bytes
  final int totalMemory;

  /// Memory usage percentage
  final double usagePercentage;

  /// Timestamp when memory was measured
  final DateTime timestamp;

  /// Creates a copy of this object with the given fields replaced by new values.
  MemoryData copyWith({
    int? currentUsage,
    int? peakUsage,
    int? availableMemory,
    int? totalMemory,
    double? usagePercentage,
    DateTime? timestamp,
  }) {
    return MemoryData(
      currentUsage: currentUsage ?? this.currentUsage,
      peakUsage: peakUsage ?? this.peakUsage,
      availableMemory: availableMemory ?? this.availableMemory,
      totalMemory: totalMemory ?? this.totalMemory,
      usagePercentage: usagePercentage ?? this.usagePercentage,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Converts bytes to megabytes
  double get currentUsageMB => currentUsage / (1024 * 1024);

  /// Converts bytes to megabytes
  double get peakUsageMB => peakUsage / (1024 * 1024);

  /// Converts bytes to megabytes
  double get availableMemoryMB => availableMemory / (1024 * 1024);

  /// Converts bytes to megabytes
  double get totalMemoryMB => totalMemory / (1024 * 1024);

  @override
  String toString() {
    return 'MemoryData(currentUsage: ${currentUsageMB.toStringAsFixed(2)}MB, '
        'peakUsage: ${peakUsageMB.toStringAsFixed(2)}MB, '
        'availableMemory: ${availableMemoryMB.toStringAsFixed(2)}MB, '
        'totalMemory: ${totalMemoryMB.toStringAsFixed(2)}MB, '
        'usagePercentage: ${usagePercentage.toStringAsFixed(2)}%, '
        'timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryData &&
        other.currentUsage == currentUsage &&
        other.peakUsage == peakUsage &&
        other.availableMemory == availableMemory &&
        other.totalMemory == totalMemory &&
        other.usagePercentage == usagePercentage &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentUsage,
      peakUsage,
      availableMemory,
      totalMemory,
      usagePercentage,
      timestamp,
    );
  }
}
