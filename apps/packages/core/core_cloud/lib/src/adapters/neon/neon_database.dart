import 'package:postgres/postgres.dart';

import '../../contracts/cloud_collection.dart';
import '../../contracts/cloud_database.dart';
import '../../contracts/cloud_storage.dart';
import 'neon_collection.dart';
import 'neon_storage_adapter.dart';

/// Neon / Postgres [CloudDatabase] using a single [Connection].
final class NeonDatabase implements CloudDatabase {
  NeonDatabase({
    required Connection connection,
    this.pollInterval = const Duration(seconds: 5),
  }) : _connection = connection,
       _storage = NeonStorageAdapter();

  final Connection _connection;
  final Duration pollInterval;
  final NeonStorageAdapter _storage;

  @override
  CloudCollection<T> collection<T>(
    String name,
    T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic> Function(T value) toJson,
  ) {
    return NeonCollection<T>(
      collectionName: name,
      fromJson: fromJson,
      toJson: toJson,
      connection: _connection,
      pollInterval: pollInterval,
    );
  }

  @override
  CloudStorage get storage => _storage;
}
