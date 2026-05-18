import 'package:core_network/src/http/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthInterceptor', () {
    late RequestOptions options;
    late bool nextCalled;

    Future<void> runInterceptor({
      required Future<String?> Function() getToken,
    }) async {
      nextCalled = false;
      options = RequestOptions(path: '/x');
      final interceptor = AuthInterceptor(getToken);
      await interceptor.onRequest(
        options,
        _CapturingHandler(() => nextCalled = true),
      );
    }

    test('adds Bearer header when token is non-empty', () async {
      await runInterceptor(getToken: () async => 'abc');
      expect(options.headers['Authorization'], 'Bearer abc');
      expect(nextCalled, isTrue);
    });

    test('omits Authorization when token is null', () async {
      await runInterceptor(getToken: () async => null);
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(nextCalled, isTrue);
    });

    test('omits Authorization when token is empty', () async {
      await runInterceptor(getToken: () async => '');
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(nextCalled, isTrue);
    });
  });
}

final class _CapturingHandler extends RequestInterceptorHandler {
  _CapturingHandler(this._onNext);

  final void Function() _onNext;

  @override
  void next(RequestOptions options) {
    _onNext();
  }
}
