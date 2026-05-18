import 'package:core_auth/src/impl/profile_exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final requestOptions = RequestOptions(
    path: '/v1/users/me',
    baseUrl: 'http://localhost:8080',
  );

  group('ProfileFetchException', () {
    test('isAuthFailure for 401 and 403', () {
      expect(
        ProfileFetchException('unauthorized', statusCode: 401).isAuthFailure,
        isTrue,
      );
      expect(
        ProfileFetchException('forbidden', statusCode: 403).isAuthFailure,
        isTrue,
      );
    });

    test('isAuthFailure false for other status codes', () {
      expect(
        ProfileFetchException('error', statusCode: 500).isAuthFailure,
        isFalse,
      );
    });

    test('isNetworkFailure for Dio connection and timeout types', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.unknown,
      ]) {
        final cause = DioException(requestOptions: requestOptions, type: type);
        expect(
          ProfileFetchException('net', cause: cause).isNetworkFailure,
          isTrue,
          reason: '$type',
        );
      }
    });

    test('isNetworkFailure when statusCode is null without Dio cause', () {
      expect(
        ProfileFetchException('offline', statusCode: null).isNetworkFailure,
        isTrue,
      );
    });

    test('isNetworkFailure false when statusCode is set without Dio cause', () {
      expect(
        ProfileFetchException('server', statusCode: 500).isNetworkFailure,
        isFalse,
      );
    });
  });
}
