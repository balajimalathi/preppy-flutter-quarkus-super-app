import 'package:riverpod/riverpod.dart';

import 'environment.dart';

/// Single place that reads `--dart-define` / `--dart-define-from-file` values.
final class AppEnv {
  const AppEnv({
    required this.environment,
    required this.baseUrl,
    required this.firebaseProjectId,
    required this.analyticsEnabled,
    required this.crashlyticsEnabled,
    required this.analyticsBackends,
  });

  final Environment environment;
  final String baseUrl;
  final String firebaseProjectId;
  final bool analyticsEnabled;
  final bool crashlyticsEnabled;

  /// Lowercase backend ids from `ANALYTICS_BACKENDS` (e.g. `firebase,posthog`).
  final List<String> analyticsBackends;

  factory AppEnv.fromEnvironment() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    const backendsRaw = String.fromEnvironment(
      'ANALYTICS_BACKENDS',
      defaultValue: 'firebase',
    );
    return AppEnv(
      environment: switch (env) {
        'prod' => const ProdEnvironment(),
        'staging' => const StagingEnvironment(),
        _ => const DevEnvironment(),
      },
      baseUrl: const String.fromEnvironment('BASE_URL'),
      firebaseProjectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      analyticsEnabled:
          const String.fromEnvironment('ANALYTICS_ENABLED') == 'true',
      crashlyticsEnabled:
          const String.fromEnvironment('CRASHLYTICS_ENABLED') == 'true',
      analyticsBackends: _parseAnalyticsBackends(backendsRaw),
    );
  }

  static List<String> _parseAnalyticsBackends(String raw) {
    final parts = raw
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return const ['firebase'];
    }
    return List<String>.unmodifiable(parts);
  }

  bool get isDev => environment is DevEnvironment;
  bool get isStaging => environment is StagingEnvironment;
  bool get isProd => environment is ProdEnvironment;
}

/// Overridden at app bootstrap with [AppEnv.fromEnvironment()].
final appEnvProvider = Provider<AppEnv>(
  (ref) => throw UnsupportedError(
    'appEnvProvider must be overridden via ProviderScope at bootstrap.',
  ),
);
