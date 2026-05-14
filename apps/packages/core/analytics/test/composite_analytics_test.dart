import 'package:core_analytics/src/analytics_contract.dart';
import 'package:core_analytics/src/impl/composite_analytics.dart';
import 'package:core_analytics/src/impl/noop_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CompositeAnalytics forwards logEvent to all children', () async {
    final a = _FakeAnalytics();
    final b = _FakeAnalytics();
    final composite = CompositeAnalytics([a, b]);
    await composite.logEvent('tap', parameters: {'x': 1});
    expect(a.events.length, 1);
    expect(a.events[0].$1, 'tap');
    expect(a.events[0].$2, {'x': 1});
    expect(b.events.length, 1);
    expect(b.events[0].$1, 'tap');
    expect(b.events[0].$2, {'x': 1});
  });

  test('NoopAnalytics completes without side effects', () async {
    const n = NoopAnalytics();
    await n.logEvent('x');
    await n.setUserId('u');
    await n.setUserProperty('p', 'v');
    await n.logScreenView('Home');
  });
}

final class _FakeAnalytics implements AnalyticsContract {
  final List<(String name, Map<String, Object?>? params)> events = [];

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    events.add((name, parameters));
  }

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
