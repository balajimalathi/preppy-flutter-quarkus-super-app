import 'package:core_env/core_env.dart';

/// Minimal [AppEnv] for provider smoke tests in this package.
AppEnv testAppEnv() {
  return const AppEnv(
    environment: DevEnvironment(),
    baseUrl: 'https://api.test',
    firebaseProjectId: 'test-project',
    authBackend: AuthBackend.firebase,
    analyticsEnabled: false,
    crashlyticsEnabled: false,
    analyticsBackends: ['firebase'],
    grpcHost: 'grpc.test',
    grpcPort: 443,
    grpcUseTls: true,
    graphqlUrl: 'https://api.test/graphql',
  );
}
