import 'package:riverpod/riverpod.dart';

import 'environment.dart';

/// Single place that reads `--dart-define` / `--dart-define-from-file` values.
final class AppEnv {
  const AppEnv({
    required this.environment,
    required this.baseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.firebaseProjectId,
    required this.analyticsEnabled,
    required this.crashlyticsEnabled,
  });

  final Environment environment;
  final String baseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String firebaseProjectId;
  final bool analyticsEnabled;
  final bool crashlyticsEnabled;

  factory AppEnv.fromEnvironment() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return AppEnv(
      environment: switch (env) {
        'prod' => const ProdEnvironment(),
        'staging' => const StagingEnvironment(),
        _ => const DevEnvironment(),
      },
      baseUrl: const String.fromEnvironment('BASE_URL'),
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      firebaseProjectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      analyticsEnabled:
          const String.fromEnvironment('ANALYTICS_ENABLED') == 'true',
      crashlyticsEnabled:
          const String.fromEnvironment('CRASHLYTICS_ENABLED') == 'true',
    );
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
