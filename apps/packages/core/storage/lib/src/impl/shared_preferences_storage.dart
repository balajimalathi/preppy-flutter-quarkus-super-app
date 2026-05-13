import 'package:shared_preferences/shared_preferences.dart';

import '../base_storage.dart';

/// [SharedPreferences]-backed string storage.
final class SharedPreferencesStorage extends BaseStorage {
  SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesStorage> open() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesStorage(prefs);
  }

  @override
  Future<void> clearRaw() => _prefs.clear();

  @override
  Future<bool> containsKeyRaw(String key) async => _prefs.containsKey(key);

  @override
  Future<void> deleteRaw(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<String?> readRaw(String key) async => _prefs.getString(key);

  @override
  Future<void> writeRaw(String key, String value) async {
    await _prefs.setString(key, value);
  }
}
