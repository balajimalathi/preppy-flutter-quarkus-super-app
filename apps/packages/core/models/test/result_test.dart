import 'package:core_models/core_models.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('success maps to ApiResult.success', () {
      const result = Result<int>.success(7);
      expect(result, const Success<int>(7));
      expect(result.toApiResult(), const ApiResult<int>.success(7));
    });

    test('failure maps to ApiResult.error', () {
      const failure = NetworkFailure(message: 'offline', code: 503);
      const result = Result<int>.failure(failure);
      final api = result.toApiResult();
      expect(api, isA<ApiError<int>>());
      expect((api as ApiError<int>).message, 'offline');
      expect(api.code, 503);
    });

    test('when dispatches both variants', () {
      expect(
        const Result<String>.success(
          'ok',
        ).when(success: (d) => 's:$d', onFailure: (f) => 'f:${f.message}'),
        's:ok',
      );
      expect(
        const Result<String>.failure(
          CacheFailure(message: 'empty'),
        ).when(success: (d) => 's:$d', onFailure: (f) => 'f:${f.message}'),
        'f:empty',
      );
    });
  });
}
