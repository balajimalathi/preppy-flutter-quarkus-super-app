/// Analytics contract for the app (Firebase/GA4, PostHog, Mixpanel, etc.).
abstract interface class AnalyticsContract {
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});

  Future<void> setUserId(String? id);

  Future<void> setUserProperty(String name, String? value);

  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
    Map<String, Object?>? parameters,
  });
}

/// Thrown when an analytics backend rejects input or fails unexpectedly.
final class AnalyticsException implements Exception {
  AnalyticsException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => cause != null ? '$message (cause: $cause)' : message;
}
