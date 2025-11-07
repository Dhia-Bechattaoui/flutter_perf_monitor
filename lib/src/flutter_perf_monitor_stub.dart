// Stub file for conditional imports
// Used when dart:io is not available (web) or when dart:js is not available (non-web)

/// Stub ProcessInfo class for web platform
class ProcessInfo {
  /// Stub property - always returns 0 on web
  static int get currentRss => 0;
}

/// Stub JsObject for non-web platforms
class JsObject {
  dynamic operator [](String key) => null;

  /// Stub callMethod that returns null
  dynamic callMethod(String method, [List? args]) => null;
}

// Stub for js.context - top-level variable to match dart:js structure
final JsObject context = JsObject();
