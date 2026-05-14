import '../models/cloud_document.dart';

/// Transaction-scoped reads and writes. Pass [fromJson]/[toJson] per operation so
/// the adapter can deserialize without a global collection registry.
abstract interface class CloudTransaction {
  Future<CloudDocument<T>> get<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic> json) fromJson,
  );

  void set<T>(
    String collection,
    String id,
    T data,
    Map<String, dynamic> Function(T value) toJson,
  );

  void update(String collection, String id, Map<String, dynamic> partial);

  void delete(String collection, String id);
}
