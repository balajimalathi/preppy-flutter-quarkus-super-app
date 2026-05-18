import 'package:core_env/core_env.dart';
import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:riverpod/riverpod.dart';

import 'test_app_env.dart';

final _grpcCallOptionsProvider = FutureProvider<CallOptions>(
  (ref) => grpcCallOptions(ref),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('grpcCallOptions', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('includes bearer metadata when token is set', () async {
      container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(testAppEnv()),
          authTokenProvider.overrideWithValue(() async => 'jwt'),
        ],
      );
      final options = await container.read(_grpcCallOptionsProvider.future);
      expect(options.metadata['authorization'], 'Bearer jwt');
    });

    test('returns empty metadata when token is null', () async {
      container = ProviderContainer(
        overrides: [appEnvProvider.overrideWithValue(testAppEnv())],
      );
      final options = await container.read(_grpcCallOptionsProvider.future);
      expect(options.metadata, isEmpty);
    });

    test('returns empty metadata when token is empty', () async {
      container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(testAppEnv()),
          authTokenProvider.overrideWithValue(() async => ''),
        ],
      );
      final options = await container.read(_grpcCallOptionsProvider.future);
      expect(options.metadata, isEmpty);
    });
  });

  group('grpc providers smoke', () {
    test('grpcChannelProvider and rpcSurfaceClientProvider build', () {
      final container = ProviderContainer(
        overrides: [appEnvProvider.overrideWithValue(testAppEnv())],
      );
      addTearDown(container.dispose);

      final channel = container.read(grpcChannelProvider);
      expect(channel, isA<ClientChannel>());

      final client = container.read(rpcSurfaceClientProvider);
      expect(client, isNotNull);
    });
  });
}
