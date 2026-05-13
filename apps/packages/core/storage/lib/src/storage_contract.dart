/// Storage contract for the app.
abstract interface class StorageContract {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<bool> containsKey(String key);
  Future<void> clear();
}

/// Thrown when storage operations fail or keys are invalid.
final class StorageException implements Exception {
  StorageException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => cause != null ? '$message (cause: $cause)' : message;
}
