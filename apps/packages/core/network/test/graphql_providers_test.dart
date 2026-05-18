import 'package:core_env/core_env.dart';
import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:riverpod/riverpod.dart';

import 'test_app_env.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('graphQLClientProvider', () {
    test('builds client with cache when env is overridden', () {
      final container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(testAppEnv()),
          authTokenProvider.overrideWithValue(() async => null),
        ],
      );
      addTearDown(container.dispose);

      final client = container.read(graphQLClientProvider);
      expect(client, isA<GraphQLClient>());
      expect(client.cache, isA<GraphQLCache>());
    });
  });

  group('dashboardHeartbeatQuery', () {
    test('document is non-empty', () {
      expect(dashboardHeartbeatQuery.definitions, isNotEmpty);
    });
  });
}
