import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorageException', () {
    test('toString without cause returns message only', () {
      final ex = StorageException('Invalid storage key');
      expect(ex.toString(), 'Invalid storage key');
    });

    test('toString with cause includes cause', () {
      final ex = StorageException('read failed', cause: StateError('backend'));
      expect(ex.toString(), contains('read failed'));
      expect(ex.toString(), contains('cause:'));
      expect(ex.toString(), contains('backend'));
    });

    test('implements Exception', () {
      expect(StorageException('x'), isA<Exception>());
    });
  });
}
