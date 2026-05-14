import 'package:core_env/core_env.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod/riverpod.dart';

import 'analytics_contract.dart';
import 'impl/composite_analytics.dart';
import 'impl/firebase_analytics_impl.dart';
import 'impl/noop_analytics.dart';

/// Resolves [AnalyticsContract] from [appEnvProvider] (backends + enabled flag).
final analyticsProvider = Provider<AnalyticsContract>((ref) {
  final env = ref.watch(appEnvProvider);
  return resolveAnalytics(env);
});

/// Build-time selection of analytics sinks (comma-separated `ANALYTICS_BACKENDS`).
AnalyticsContract resolveAnalytics(AppEnv env) {
  if (!env.analyticsEnabled) {
    return const NoopAnalytics();
  }
  final backends = env.analyticsBackends.isEmpty
      ? const <String>['firebase']
      : env.analyticsBackends;
  final impls = <AnalyticsContract>[];
  for (final id in backends) {
    switch (id) {
      case 'firebase':
        impls.add(FirebaseAnalyticsImpl(FirebaseAnalytics.instance));
      // posthog, mixpanel: add impls when SDKs are wired.
      default:
        break;
    }
  }
  if (impls.isEmpty) {
    return const NoopAnalytics();
  }
  if (impls.length == 1) {
    return impls.single;
  }
  return CompositeAnalytics(impls);
}
