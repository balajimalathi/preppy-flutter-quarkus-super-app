import 'package:core_storage/core_storage.dart';
import 'package:core_storage/src/base_storage.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FailingStorage extends BaseStorage {
  _FailingStorage({
    this.failOnRead,
    this.failOnWrite,
    this.failOnDelete,
    this.failOnContainsKey,
    this.failOnClear,
  });

  final bool? failOnRead;
  final bool? failOnWrite;
  final bool? failOnDelete;
  final bool? failOnContainsKey;
  final bool? failOnClear;

  static final _backendError = StateError('backend');

  @override
  Future<void> clearRaw() async {
    if (failOnClear ?? false) throw _backendError;
  }

  @override
  Future<bool> containsKeyRaw(String key) async {
    if (failOnContainsKey ?? false) throw _backendError;
    return false;
  }

  @override
  Future<void> deleteRaw(String key) async {
    if (failOnDelete ?? false) throw _backendError;
  }

  @override
  Future<String?> readRaw(String key) async {
    if (failOnRead ?? false) throw _backendError;
    return null;
  }

  @override
  Future<void> writeRaw(String key, String value) async {
    if (failOnWrite ?? false) throw _backendError;
  }
}

void main() {
  group('BaseStorage error wrapping', () {
    test('read wraps backend errors in StorageException', () async {
      final storage = _FailingStorage(failOnRead: true);
      expect(
        () => storage.read('key'),
        throwsA(
          isA<StorageException>()
              .having((e) => e.cause, 'cause', isA<StateError>())
              .having((e) => e.message, 'message', 'read failed'),
        ),
      );
    });

    test('write wraps backend errors in StorageException', () async {
      final storage = _FailingStorage(failOnWrite: true);
      expect(
        () => storage.write('key', 'value'),
        throwsA(
          isA<StorageException>()
              .having((e) => e.cause, 'cause', isA<StateError>())
              .having((e) => e.message, 'message', 'write failed'),
        ),
      );
    });

    test('delete wraps backend errors in StorageException', () async {
      final storage = _FailingStorage(failOnDelete: true);
      expect(
        () => storage.delete('key'),
        throwsA(
          isA<StorageException>()
              .having((e) => e.cause, 'cause', isA<StateError>())
              .having((e) => e.message, 'message', 'delete failed'),
        ),
      );
    });

    test('containsKey wraps backend errors in StorageException', () async {
      final storage = _FailingStorage(failOnContainsKey: true);
      expect(
        () => storage.containsKey('key'),
        throwsA(
          isA<StorageException>()
              .having((e) => e.cause, 'cause', isA<StateError>())
              .having((e) => e.message, 'message', 'containsKey failed'),
        ),
      );
    });

    test('clear wraps backend errors in StorageException', () async {
      final storage = _FailingStorage(failOnClear: true);
      expect(
        () => storage.clear(),
        throwsA(
          isA<StorageException>()
              .having((e) => e.cause, 'cause', isA<StateError>())
              .having((e) => e.message, 'message', 'clear failed'),
        ),
      );
    });

    test('clear succeeds without key validation', () async {
      final storage = _FailingStorage();
      await expectLater(storage.clear(), completes);
    });
  });
}
