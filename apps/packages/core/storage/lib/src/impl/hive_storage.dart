import 'package:hive_ce/hive.dart';

import '../base_storage.dart';

/// Hive-backed storage. Call [Hive.initFlutter] (or [Hive.init]) before use.
final class HiveStorage extends BaseStorage {
  HiveStorage({String boxName = 'core_storage'}) : _boxName = boxName;

  final String _boxName;
  Box<String>? _box;

  Future<Box<String>> get _boxAsync async {
    final cached = _box;
    if (cached != null && cached.isOpen) {
      return cached;
    }
    final opened = await Hive.openBox<String>(_boxName);
    _box = opened;
    return opened;
  }

  @override
  Future<void> clearRaw() async {
    final box = await _boxAsync;
    await box.clear();
  }

  @override
  Future<bool> containsKeyRaw(String key) async {
    final box = await _boxAsync;
    return box.containsKey(key);
  }

  @override
  Future<void> deleteRaw(String key) async {
    final box = await _boxAsync;
    await box.delete(key);
  }

  @override
  Future<String?> readRaw(String key) async {
    final box = await _boxAsync;
    return box.get(key);
  }

  @override
  Future<void> writeRaw(String key, String value) async {
    final box = await _boxAsync;
    await box.put(key, value);
  }
}
