import 'cloud_collection.dart';
import 'cloud_storage.dart';

/// Factory for typed collections plus [storage] for the same backend.
abstract interface class CloudDatabase {
  /// Returns a typed collection facade for the logical collection [name].
  CloudCollection<T> collection<T>(
    String name,
    T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic> Function(T value) toJson,
  );

  /// Object storage bound to the same logical backend.
  CloudStorage get storage;
}
