import 'package:core_models/core_models.dart';
import 'package:test/test.dart';

void main() {
  group('ResultGetOrThrow', () {
    test('getOrThrow returns data on success', () {
      const result = Result<String>.success('ok');
      expect(result.getOrThrow(), 'ok');
    });

    test('getOrThrow throws AppError on failure', () {
      const result = Result<String>.failure(CacheFailure(message: 'no cache'));
      expect(() => result.getOrThrow(), throwsA(isA<NetworkError>()));
    });
  });
}
