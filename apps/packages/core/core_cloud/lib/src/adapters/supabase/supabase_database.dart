import 'package:supabase_flutter/supabase_flutter.dart';

import '../../contracts/cloud_collection.dart';
import '../../contracts/cloud_database.dart';
import '../../contracts/cloud_storage.dart';
import 'supabase_collection.dart';
import 'supabase_storage_adapter.dart';

/// Supabase (PostgREST + Realtime stream + Storage) [CloudDatabase].
final class SupabaseDatabase implements CloudDatabase {
  SupabaseDatabase(SupabaseClient client, {String storageBucket = 'public'})
    : _client = client,
      _storage = SupabaseStorageAdapter(client: client, bucket: storageBucket);

  final SupabaseClient _client;
  final SupabaseStorageAdapter _storage;

  @override
  CloudCollection<T> collection<T>(
    String name,
    T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic> Function(T value) toJson,
  ) {
    return SupabaseCollection<T>(
      collectionName: name,
      fromJson: fromJson,
      toJson: toJson,
      client: _client,
    );
  }

  @override
  CloudStorage get storage => _storage;
}
