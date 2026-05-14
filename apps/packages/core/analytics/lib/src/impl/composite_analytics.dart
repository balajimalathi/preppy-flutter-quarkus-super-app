import '../analytics_contract.dart';

/// Forwards every call to all [children] (e.g. Firebase + PostHog).
final class CompositeAnalytics implements AnalyticsContract {
  CompositeAnalytics(Iterable<AnalyticsContract> children)
    : _children = List<AnalyticsContract>.unmodifiable(
        List<AnalyticsContract>.from(children),
      );

  final List<AnalyticsContract> _children;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    for (final c in _children) {
      await c.logEvent(name, parameters: parameters);
    }
  }

  @override
  Future<void> setUserId(String? id) async {
    for (final c in _children) {
      await c.setUserId(id);
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    for (final c in _children) {
      await c.setUserProperty(name, value);
    }
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
    Map<String, Object?>? parameters,
  }) async {
    for (final c in _children) {
      await c.logScreenView(
        screenName,
        screenClass: screenClass,
        parameters: parameters,
      );
    }
  }
}
