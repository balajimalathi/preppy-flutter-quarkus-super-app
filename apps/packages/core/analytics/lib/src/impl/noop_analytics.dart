import '../analytics_contract.dart';

/// No-op implementation for tests and when analytics collection is disabled.
final class NoopAnalytics implements AnalyticsContract {
  const NoopAnalytics();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}

  @override
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
    Map<String, Object?>? parameters,
  }) async {}
}
