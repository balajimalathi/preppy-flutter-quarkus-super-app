import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../base_storage.dart';

/// Encrypted key-value storage via [FlutterSecureStorage].
final class SecureStorage extends BaseStorage {
  SecureStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> clearRaw() => _storage.deleteAll();

  @override
  Future<bool> containsKeyRaw(String key) async =>
      await _storage.containsKey(key: key);

  @override
  Future<void> deleteRaw(String key) => _storage.delete(key: key);

  @override
  Future<String?> readRaw(String key) => _storage.read(key: key);

  @override
  Future<void> writeRaw(String key, String value) =>
      _storage.write(key: key, value: value);
}
