import 'package:core_storage/core_storage.dart';
import 'package:core_storage/src/impl/shared_preferences_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = SharedPreferencesStorage(prefs);
  });

  test('write then read returns value', () async {
    await storage.write('k', 'v');
    expect(await storage.read('k'), 'v');
  });

  test('delete removes key', () async {
    await storage.write('k', 'v');
    await storage.delete('k');
    expect(await storage.read('k'), isNull);
    expect(await storage.containsKey('k'), isFalse);
  });

  test('containsKey reflects prefs', () async {
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

  test('empty key throws StorageException', () async {
    Future<Object?> catchRead(String key) async {
      try {
        await storage.read(key);
        return null;
      } catch (e) {
        return e;
      }
    }

    Future<Object?> catchWrite(String key, String value) async {
      try {
        await storage.write(key, value);
        return null;
      } catch (e) {
        return e;
      }
    }

    expect(await catchRead(''), isA<StorageException>());
    expect(await catchRead('   '), isA<StorageException>());
    expect(await catchWrite('', 'x'), isA<StorageException>());
  });
}
