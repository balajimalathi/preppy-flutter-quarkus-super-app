import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'storage_contract.dart';

/// Shared validation, debug logging, and error wrapping for storage backends.
abstract base class BaseStorage implements StorageContract {
  static const _logName = 'core_storage';

  void _validateKey(String key) {
    if (key.trim().isEmpty) {
      throw StorageException('Invalid storage key: must be non-empty');
    }
  }

  Future<T> _run<T>(
    String operation,
    String keyLabel,
    Future<T> Function() action,
  ) async {
    try {
      final result = await action();
      if (kDebugMode) {
        developer.log('$operation ok ($keyLabel)', name: _logName);
      }
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        developer.log(
          '$operation failed ($keyLabel): $e',
          name: _logName,
          error: e,
          stackTrace: st,
        );
      }
      Error.throwWithStackTrace(
        StorageException('$operation failed', cause: e, stackTrace: st),
        st,
      );
    }
  }

  Future<void> _runVoidNoKey(
    String operation,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      if (kDebugMode) {
        developer.log('$operation ok', name: _logName);
      }
    } catch (e, st) {
      if (kDebugMode) {
        developer.log(
          '$operation failed: $e',
          name: _logName,
          error: e,
          stackTrace: st,
        );
      }
      Error.throwWithStackTrace(
        StorageException('$operation failed', cause: e, stackTrace: st),
        st,
      );
    }
  }

  String _keyLabel(String key) => 'key=${_truncate(key)}';

  String _truncate(String key) =>
      key.length > 48 ? '${key.substring(0, 48)}…' : key;

  @override
  Future<void> clear() => _runVoidNoKey('clear', clearRaw);

  @override
  Future<bool> containsKey(String key) {
    _validateKey(key);
    return _run('containsKey', _keyLabel(key), () => containsKeyRaw(key));
  }

  @override
  Future<void> delete(String key) {
    _validateKey(key);
    return _runVoid('delete', _keyLabel(key), () => deleteRaw(key));
  }

  @override
  Future<String?> read(String key) {
    _validateKey(key);
    return _run('read', _keyLabel(key), () => readRaw(key));
  }

  @override
  Future<void> write(String key, String value) {
    _validateKey(key);
    return _runVoid('write', _keyLabel(key), () => writeRaw(key, value));
  }

  Future<void> _runVoid(
    String operation,
    String keyLabel,
    Future<void> Function() action,
  ) => _run(operation, keyLabel, () async {
    await action();
  });

  @protected
  Future<void> clearRaw();

  @protected
  Future<bool> containsKeyRaw(String key);

  @protected
  Future<void> deleteRaw(String key);

  @protected
  Future<String?> readRaw(String key);

  @protected
  Future<void> writeRaw(String key, String value);
}
