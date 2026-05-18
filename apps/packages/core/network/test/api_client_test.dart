import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiClient / dioProvider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('dioProvider uses overridden baseUrl', () {
      container = ProviderContainer(
        overrides: [
          baseUrlProvider.overrideWithValue('https://api.test'),
          authTokenProvider.overrideWithValue(() async => null),
        ],
      );
      final dio = container.read(dioProvider);
      expect(dio.options.baseUrl, 'https://api.test');
    });

    test('dio attaches Bearer token on requests', () async {
      container = ProviderContainer(
        overrides: [
          baseUrlProvider.overrideWithValue('https://api.test'),
          authTokenProvider.overrideWithValue(() async => 'tok'),
        ],
      );
      final dio = container.read(dioProvider);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['Authorization'], 'Bearer tok');
            handler.resolve(Response(requestOptions: options));
          },
        ),
      );
      await dio.get<void>('/x');
    });

    test('dio omits Authorization when token is null', () async {
      container = ProviderContainer(
        overrides: [baseUrlProvider.overrideWithValue('https://api.test')],
      );
      final dio = container.read(dioProvider);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers.containsKey('Authorization'), isFalse);
            handler.resolve(Response(requestOptions: options));
          },
        ),
      );
      await dio.get<void>('/x');
    });

    test('container dispose closes dio without error', () {
      container = ProviderContainer(
        overrides: [baseUrlProvider.overrideWithValue('https://api.test')],
      );
      container.read(dioProvider);
      expect(() => container.dispose(), returnsNormally);
      container = ProviderContainer(
        overrides: [baseUrlProvider.overrideWithValue('https://api.test')],
      );
    });
  });
}
