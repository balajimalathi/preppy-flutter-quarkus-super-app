/// Analytics package entrypoint.
///
/// Exposes the shared [AnalyticsContract] abstraction, Riverpod provider wiring,
/// and the Firebase Analytics type used by the default implementation.
library;

export 'package:firebase_analytics/firebase_analytics.dart'
    show FirebaseAnalytics;

export 'src/analytics_contract.dart';
export 'src/analytics_provider.dart';
