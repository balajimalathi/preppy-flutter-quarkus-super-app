import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared [StorageContract] behavior tests for any backend implementation.
void runStorageContractTests({
  required String name,
  required Future<StorageContract> Function() createStorage,
  Future<void> Function()? setUpStorage,
  Future<void> Function()? tearDownStorage,
}) {
  group('$name StorageContract', () {
    late StorageContract storage;

    setUp(() async {
      await setUpStorage?.call();
      storage = await createStorage();
    });

    tearDown(() async {
      await tearDownStorage?.call();
    });

    test('write then read returns value', () async {
      await storage.write('k', 'v');
      expect(await storage.read('k'), 'v');
    });

    test('read missing key returns null', () async {
      expect(await storage.read('missing'), isNull);
    });

    test('overwrite updates value', () async {
      await storage.write('k', 'v1');
      await storage.write('k', 'v2');
      expect(await storage.read('k'), 'v2');
    });

    test('delete removes key', () async {
      await storage.write('k', 'v');
      await storage.delete('k');
      expect(await storage.read('k'), isNull);
      expect(await storage.containsKey('k'), isFalse);
    });

    test('containsKey reflects stored keys', () async {
      expect(await storage.containsKey('x'), isFalse);
      await storage.write('x', 'y');
      expect(await storage.containsKey('x'), isTrue);
    });

    test('clear removes all keys', () async {
      await storage.write('a', '1');
      await storage.write('b', '2');
      await storage.clear();
      expect(await storage.containsKey('a'), isFalse);
      expect(await storage.containsKey('b'), isFalse);
    });

    test('empty or whitespace key throws StorageException', () async {
      Future<Object?> catchOp(Future<void> Function() op) async {
        try {
          await op();
          return null;
        } catch (e) {
          return e;
        }
      }

      Future<Object?> catchRead(String key) => catchOp(() => storage.read(key));

      Future<Object?> catchWrite(String key, String value) =>
          catchOp(() => storage.write(key, value));

      Future<Object?> catchDelete(String key) =>
          catchOp(() => storage.delete(key));

      Future<Object?> catchContains(String key) =>
          catchOp(() => storage.containsKey(key));

      expect(await catchRead(''), isA<StorageException>());
      expect(await catchRead('   '), isA<StorageException>());
      expect(await catchWrite('', 'x'), isA<StorageException>());
      expect(await catchWrite('   ', 'x'), isA<StorageException>());
      expect(await catchDelete(''), isA<StorageException>());
      expect(await catchContains(''), isA<StorageException>());
    });

    test('clear does not validate keys', () async {
      await storage.write('a', '1');
      await expectLater(storage.clear(), completes);
    });
  });
}
