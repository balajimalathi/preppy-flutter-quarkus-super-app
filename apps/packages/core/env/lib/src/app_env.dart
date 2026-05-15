import 'package:riverpod/riverpod.dart';

import 'auth_backend.dart';
import 'environment.dart';

/// Single place that reads `--dart-define` / `--dart-define-from-file` values.
final class AppEnv {
  const AppEnv({
    required this.environment,
    required this.baseUrl,
    required this.firebaseProjectId,
    required this.authBackend,
    required this.analyticsEnabled,
    required this.crashlyticsEnabled,
    required this.analyticsBackends,
    required this.grpcHost,
    required this.grpcPort,
    required this.grpcUseTls,
    required this.graphqlUrl,
  });

  final Environment environment;
  final String baseUrl;
  final String firebaseProjectId;

  /// Active auth IdP (`AUTH_BACKEND`, default [AuthBackend.firebase]).
  final AuthBackend authBackend;
  final bool analyticsEnabled;
  final bool crashlyticsEnabled;

  /// Lowercase backend ids from `ANALYTICS_BACKENDS` (e.g. `firebase,posthog`).
  final List<String> analyticsBackends;

  /// Optional override for gRPC host. When empty, derived from [baseUrl] host.
  final String grpcHost;

  /// gRPC port (e.g. 443 for TLS).
  final int grpcPort;

  /// Use TLS credentials when true (typical production).
  final bool grpcUseTls;

  /// Full GraphQL HTTP endpoint. When empty, derived as `<BASE_URL>/graphql`.
  final String graphqlUrl;

  factory AppEnv.fromEnvironment() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    const backendsRaw = String.fromEnvironment(
      'ANALYTICS_BACKENDS',
      defaultValue: 'firebase',
    );
    const grpcPortRaw = String.fromEnvironment(
      'GRPC_PORT',
      defaultValue: '443',
    );
    const grpcTlsRaw = String.fromEnvironment('GRPC_TLS', defaultValue: 'true');
    const authBackendRaw = String.fromEnvironment(
      'AUTH_BACKEND',
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
      authBackend: AuthBackend.parse(authBackendRaw),
      analyticsEnabled:
          const String.fromEnvironment('ANALYTICS_ENABLED') == 'true',
      crashlyticsEnabled:
          const String.fromEnvironment('CRASHLYTICS_ENABLED') == 'true',
      analyticsBackends: _parseAnalyticsBackends(backendsRaw),
      grpcHost: const String.fromEnvironment('GRPC_HOST', defaultValue: ''),
      grpcPort: int.tryParse(grpcPortRaw) ?? 443,
      grpcUseTls: grpcTlsRaw.toLowerCase() != 'false',
      graphqlUrl: const String.fromEnvironment('GRAPHQL_URL', defaultValue: ''),
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

  /// REST API origin (same as [baseUrl], normalized for clarity in multi-protocol setups).
  Uri get restBaseUri => Uri.parse(baseUrl);

  String get effectiveGrpcHost {
    if (grpcHost.isNotEmpty) {
      return grpcHost;
    }
    return restBaseUri.host;
  }

  /// HttpLink URI for GraphQL over HTTP POST.
  String get graphqlHttpUrl {
    if (graphqlUrl.isNotEmpty) {
      return graphqlUrl;
    }
    final origin = '${restBaseUri.scheme}://${restBaseUri.authority}';
    return '$origin/graphql';
  }
}

/// Overridden at app bootstrap with [AppEnv.fromEnvironment()].
final appEnvProvider = Provider<AppEnv>(
  (ref) => throw UnsupportedError(
    'appEnvProvider must be overridden via ProviderScope at bootstrap.',
  ),
);
