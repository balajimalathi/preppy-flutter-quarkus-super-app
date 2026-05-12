import 'package:hive/hive.dart';

/// Tiny Hive façade so callers don't need to know about box names / typing.
class KeyValueStore<T> {
  KeyValueStore(this._box);

  final Box<T> _box;

  Future<void> put(String key, T value) => _box.put(key, value);

  T? get(String key) => _box.get(key);

  Future<void> delete(String key) => _box.delete(key);
}
