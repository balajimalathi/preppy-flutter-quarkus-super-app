import 'package:core_auth/src/providers/auth_providers.dart';
import 'package:core_env/core_env.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'helpers/auth_test_fakes.dart';

void main() {
  const unsupportedEnv = AppEnv(
    environment: DevEnvironment(),
    baseUrl: 'http://localhost:8080',
    firebaseProjectId: 'test',
    authBackend: AuthBackend.supabase,
    analyticsEnabled: false,
    crashlyticsEnabled: false,
    analyticsBackends: ['firebase'],
    grpcHost: '',
    grpcPort: 443,
    grpcUseTls: true,
    graphqlUrl: '',
  );

  test('authServiceProvider throws for unsupported auth backend', () {
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(unsupportedEnv),
        storageProvider.overrideWithValue(_NoopStorage()),
        profileServiceProvider.overrideWithValue(FakeProfileService()),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(authServiceProvider),
      throwsA(
        predicate((Object? e) => e.toString().contains('not implemented')),
      ),
    );
  });
}

final class _NoopStorage implements StorageContract {
  @override
  Future<void> clear() async {}

  @override
  Future<bool> containsKey(String key) async => false;

  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {}
}
