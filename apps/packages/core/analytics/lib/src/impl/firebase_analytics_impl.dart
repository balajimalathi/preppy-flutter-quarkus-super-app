import 'package:firebase_analytics/firebase_analytics.dart';

import '../analytics_contract.dart';
import '../analytics_parameter_codec.dart';

/// [FirebaseAnalytics] / GA4-backed implementation.
final class FirebaseAnalyticsImpl implements AnalyticsContract {
  FirebaseAnalyticsImpl(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) {
    final encoded = encodeFirebaseEventParameters(parameters);
    return _analytics.logEvent(name: name, parameters: encoded);
  }

  @override
  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  @override
  Future<void> setUserProperty(String name, String? value) {
    return _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
    Map<String, Object?>? parameters,
  }) {
    final encoded = encodeFirebaseEventParameters(parameters);
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
      parameters: encoded,
    );
  }
}
