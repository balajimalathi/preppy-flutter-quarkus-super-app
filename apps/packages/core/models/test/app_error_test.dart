import 'package:core_models/core_models.dart';
import 'package:test/test.dart';

void main() {
  group('FailureToAppError', () {
    test('maps NetworkFailure to NetworkError', () {
      const failure = NetworkFailure(message: 'timeout', code: 408);
      final error = failure.toAppError();
      expect(error, isA<NetworkError>());
      expect((error as NetworkError).statusCode, 408);
      expect(error.message, 'timeout');
    });

    test('maps CacheFailure to NetworkError', () {
      const failure = CacheFailure(message: 'no cache');
      final error = failure.toAppError();
      expect(error, isA<NetworkError>());
      expect((error as NetworkError).message, 'no cache');
    });

    test('maps UnknownFailure to UnknownError', () {
      const failure = UnknownFailure(message: 'oops');
      final error = failure.toAppError();
      expect(error, isA<UnknownError>());
    });
  });

  group('appErrorFromStatusCode', () {
    test('maps 401 to UnauthorizedError', () {
      final error = appErrorFromStatusCode(statusCode: 401, message: 'x');
      expect(error, isA<UnauthorizedError>());
    });

    test('maps 404 to NotFoundError', () {
      final error = appErrorFromStatusCode(
        statusCode: 404,
        message: 'x',
        notFoundResource: 'Dashboard',
      );
      expect(error, isA<NotFoundError>());
      expect((error as NotFoundError).resource, 'Dashboard');
    });
  });
}
