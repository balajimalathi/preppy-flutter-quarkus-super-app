import 'package:core_models/core_models.dart';
import 'package:test/test.dart';

/// Ensures [switch] on [ApiResult] stays exhaustive at compile time.
String describeResult(ApiResult<int> r) {
  return switch (r) {
    ApiIdle<int>() => 'idle',
    ApiLoading<int>(:final previousData) => 'loading:${previousData ?? 'null'}',
    ApiSuccess<int>(:final data) => 'success:$data',
    ApiError<int>(:final message, :final code, :final cause) =>
      'error:$message:$code:${cause != null}',
  };
}

void main() {
  group('ApiResult', () {
    test('idle equality and describe', () {
      const a = ApiResult<int>.idle();
      const b = ApiIdle<int>();
      expect(a, b);
      expect(describeResult(a), 'idle');
      expect(a.isIdle, isTrue);
      expect(a.isTerminal, isFalse);
      expect(a.dataOrNull, isNull);
    });

    test('loading holds previousData', () {
      const r = ApiResult<int>.loading(previousData: 1);
      expect(r, const ApiLoading<int>(previousData: 1));
      expect(describeResult(r), 'loading:1');
      expect(r.isLoading, isTrue);
      expect(r.dataOrNull, 1);
    });

    test('success', () {
      const r = ApiResult<int>.success(42);
      expect(r, const ApiSuccess<int>(42));
      expect(describeResult(r), 'success:42');
      expect(r.isSuccess, isTrue);
      expect(r.isTerminal, isTrue);
      expect(r.dataOrNull, 42);
    });

    test('error fields and fromException', () {
      const r = ApiError<int>(message: 'm', code: 400, cause: 'c');
      expect(r.message, 'm');
      expect(r.code, 400);
      expect(r.cause, 'c');
      expect(describeResult(r), 'error:m:400:true');
      expect(r.isError, isTrue);

      final fromEx = ApiError<int>.fromException(StateError('x'), code: 1);
      expect(fromEx.message, contains('Bad state'));
      expect(fromEx.code, 1);
    });

    test('when dispatches all variants', () {
      expect(
        const ApiResult<int>.idle().when(
          idle: () => 'i',
          loading: (_) => 'l',
          success: (_) => 's',
          error: (message, code, cause) => 'e',
        ),
        'i',
      );
      expect(
        const ApiResult<int>.loading().when(
          idle: () => 'i',
          loading: (_) => 'l',
          success: (_) => 's',
          error: (message, code, cause) => 'e',
        ),
        'l',
      );
    });

    test('foldTerminal', () {
      expect(
        const ApiResult<int>.idle().foldTerminal(
          onSuccess: (d) => 's$d',
          onError: (m, c, _) => 'e$m$c',
          orElse: () => 'o',
        ),
        'o',
      );
      expect(
        const ApiResult<int>.success(3).foldTerminal(
          onSuccess: (d) => 's$d',
          onError: (m, c, _) => 'e$m$c',
          orElse: () => 'o',
        ),
        's3',
      );
      expect(
        const ApiResult<int>.error(message: 'x').foldTerminal(
          onSuccess: (d) => 's$d',
          onError: (m, c, _) => 'e$m$c',
          orElse: () => 'o',
        ),
        'exnull',
      );
    });
  });
}
