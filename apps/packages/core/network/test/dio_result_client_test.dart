import 'package:core_models/core_models.dart';
import 'package:core_network/core_connectivity.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _payload = {'id': '1', 'name': 'Test'};

Map<String, dynamic> _itemFromJson(Map<String, dynamic> json) => json;

Dio _dioWithBody(Map<String, dynamic> body) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<Map<String, dynamic>>(requestOptions: options, data: body),
        );
      },
    ),
  );
  return dio;
}

final class _FakeConnectivity implements ConnectivityContract {
  _FakeConnectivity(this._status);

  ConnectivityState _status;

  set status(ConnectivityState value) => _status = value;

  @override
  Future<ConnectivityState> get currentStatus async => _status;

  @override
  Stream<ConnectivityState> get onStatusChange => Stream.value(_status);
}

void main() {
  group('dioGetEnvelope', () {
    test('returns success when envelope is valid', () async {
      final result = await dioGetEnvelope(
        dio: _dioWithBody({'data': _payload}),
        path: '/test',
        fromJson: _itemFromJson,
      );
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect((result as Success).data, _payload);
    });

    test('returns failure for empty body', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                data: null,
              ),
            );
          },
        ),
      );
      final result = await dioGetEnvelope(
        dio: dio,
        path: '/test',
        fromJson: _itemFromJson,
      );
      expect(result, isA<FailureResult>());
    });

    test('returns failure for invalid envelope', () async {
      final result = await dioGetEnvelope(
        dio: _dioWithBody({'items': _payload}),
        path: '/test',
        fromJson: _itemFromJson,
      );
      expect(result, isA<FailureResult>());
    });

    test('returns NetworkFailure on DioException', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 503),
                message: 'Service unavailable',
              ),
            );
          },
        ),
      );
      final result = await dioGetEnvelope(
        dio: dio,
        path: '/test',
        fromJson: _itemFromJson,
      );
      expect(result, isA<FailureResult>());
      final failure = (result as FailureResult).failure;
      expect(failure, isA<NetworkFailure>());
      expect(failure.code, 503);
    });

    test('returns UnknownFailure when fromJson throws', () async {
      final result = await dioGetEnvelope(
        dio: _dioWithBody({'data': _payload}),
        path: '/test',
        fromJson: (_) => throw StateError('parse error'),
      );
      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure, isA<UnknownFailure>());
    });

    test('supports custom envelopeKey', () async {
      final result = await dioGetEnvelope(
        dio: _dioWithBody({'result': _payload}),
        path: '/test',
        fromJson: _itemFromJson,
        envelopeKey: 'result',
      );
      expect(result, isA<Success<Map<String, dynamic>>>());
      expect((result as Success).data, _payload);
    });

    test('returns failure when envelope value is not a map', () async {
      final result = await dioGetEnvelope(
        dio: _dioWithBody({
          'data': [_payload],
        }),
        path: '/test',
        fromJson: _itemFromJson,
      );
      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure.message, contains('"data"'));
    });
  });

  group('fetchWithOfflineCache', () {
    test('offline returns cached value', () async {
      var saved = false;
      final result = await fetchWithOfflineCache(
        connectivity: _FakeConnectivity(ConnectivityState.offline),
        getCached: () async => _payload,
        saveCached: (_) async => saved = true,
        fetchRemote: () async =>
            const Result.failure(NetworkFailure(message: 'should not run')),
      );
      expect(result, isA<Success>());
      expect((result as Success).data, _payload);
      expect(saved, isFalse);
    });

    test('offline without cache returns CacheFailure', () async {
      final result = await fetchWithOfflineCache(
        connectivity: _FakeConnectivity(ConnectivityState.offline),
        getCached: () async => null,
        saveCached: (_) async {},
        fetchRemote: () async =>
            const Result.failure(NetworkFailure(message: 'x')),
        emptyCacheMessage: 'No cache',
      );
      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure.message, 'No cache');
    });

    test('online success persists cache', () async {
      Map<String, dynamic>? cached;
      final result = await fetchWithOfflineCache(
        connectivity: _FakeConnectivity(ConnectivityState.online),
        getCached: () async => cached,
        saveCached: (data) async => cached = data,
        fetchRemote: () async => const Result.success(_payload),
      );
      expect(result, isA<Success>());
      expect((result as Success).data, _payload);
      expect(cached, _payload);
    });

    test('online failure does not persist cache', () async {
      Map<String, dynamic>? cached;
      final result = await fetchWithOfflineCache(
        connectivity: _FakeConnectivity(ConnectivityState.online),
        getCached: () async => null,
        saveCached: (data) async => cached = data,
        fetchRemote: () async =>
            const Result.failure(NetworkFailure(message: 'network down')),
      );
      expect(result, isA<FailureResult>());
      expect(cached, isNull);
    });
  });
}
