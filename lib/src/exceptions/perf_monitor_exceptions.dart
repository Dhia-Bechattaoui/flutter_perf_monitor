/// Base exception class for Flutter Performance Monitor.
abstract class PerfMonitorException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const PerfMonitorException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    final buffer = StringBuffer('PerfMonitorException: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (originalError != null) {
      buffer.write(' (Original: $originalError)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when the performance monitor is not properly initialized.
class PerfMonitorNotInitializedException extends PerfMonitorException {
  const PerfMonitorNotInitializedException([String? message])
    : super(message ?? 'Performance monitor is not initialized');
}

/// Exception thrown when platform-specific operations fail.
class PlatformOperationException extends PerfMonitorException {
  const PlatformOperationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Exception thrown when memory monitoring fails.
class MemoryMonitoringException extends PlatformOperationException {
  /// Creates a new MemoryMonitoringException.
  ///
  /// [message] - The error message describing the memory monitoring failure
  /// [code] - Optional error code for the failure
  /// [originalError] - The original error that caused this exception
  const MemoryMonitoringException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Exception thrown when CPU monitoring fails.
class CPUMonitoringException extends PlatformOperationException {
  /// Creates a new CPUMonitoringException.
  ///
  /// [message] - The error message describing the CPU monitoring failure
  /// [code] - Optional error code for the failure
  /// [originalError] - The original error that caused this exception
  const CPUMonitoringException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Exception thrown when FPS monitoring fails.
class FPSMonitoringException extends PerfMonitorException {
  /// Creates a new FPSMonitoringException.
  ///
  /// [message] - The error message describing the FPS monitoring failure
  /// [code] - Optional error code for the failure
  /// [originalError] - The original error that caused this exception
  const FPSMonitoringException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Exception thrown when configuration is invalid.
class InvalidConfigurationException extends PerfMonitorException {
  /// Creates a new InvalidConfigurationException.
  ///
  /// [message] - The error message describing the configuration issue
  /// [code] - Optional error code for the failure
  const InvalidConfigurationException(super.message, {super.code});
}
