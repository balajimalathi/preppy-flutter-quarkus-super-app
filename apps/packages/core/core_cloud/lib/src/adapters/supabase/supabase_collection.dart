import 'package:supabase_flutter/supabase_flutter.dart';

import '../../base/base_cloud_collection.dart';
import '../../contracts/cloud_collection.dart';
import '../../contracts/cloud_transaction.dart';
import '../../models/cloud_document.dart';
import '../../models/cloud_filter.dart';
import '../../models/cloud_query.dart';
import '../../models/cloud_result.dart';
import '../../models/cloud_stream_event.dart';

final class SupabaseCollection<T> extends BaseCloudCollection<T>
    implements CloudCollection<T> {
  SupabaseCollection({
    required super.collectionName,
    required super.fromJson,
    required super.toJson,
    required SupabaseClient client,
  }) : _client = client;

  final SupabaseClient _client;

  @override
  CloudResult<R> mapException<R>(
    Object error, {
    CloudErrorCode code = CloudErrorCode.unknown,
  }) {
    if (error is PostgrestException) {
      final mapped = switch (error.code) {
        '42501' || 'PGRST301' => CloudErrorCode.permissionDenied,
        'PGRST116' => CloudErrorCode.notFound,
        _ => CloudErrorCode.unknown,
      };
      return CloudError(message: error.message, code: mapped);
    }
    return super.mapException(error, code: code);
  }

  dynamic _applySelectQuery(CloudQuery query) {
    dynamic q = _client.from(collectionName).select();
    for (final f in query.filters) {
      q = switch (f) {
        WhereEqual(:final field, :final value) => q.eq(field, value as Object),
        WhereIn(:final field, :final values) => q.inFilter(
          field,
          values.map((e) => e as Object).toList(),
        ),
        WhereLessThan(:final field, :final value) => q.lt(
          field,
          value as Object,
        ),
        WhereGreaterThan(:final field, :final value) => q.gt(
          field,
          value as Object,
        ),
        WhereContains(:final field, :final value) => q.ilike(field, '%$value%'),
      };
    }
    if (query.orderBy != null) {
      q = q.order(query.orderBy!, ascending: !query.descending);
    }
    if (query.limit != null) {
      q = q.limit(query.limit!);
    }
    return q;
  }

  CloudDocument<T> _mapRow(Map<String, dynamic> row) {
    final id = row['id']?.toString() ?? '';
    return CloudDocument(
      id: id,
      data: fromJson(Map<String, dynamic>.from(row)),
      createdAt: _readDate(row['created_at'] ?? row['createdAt']),
      updatedAt: _readDate(row['updated_at'] ?? row['updatedAt']),
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }

  @override
  Future<CloudResult<List<CloudDocument<T>>>> fetch({CloudQuery? query}) async {
    try {
      final dynamic q = query != null
          ? _applySelectQuery(query)
          : _client.from(collectionName).select();
      final rows = await q as List<dynamic>;
      final list = rows.cast<Map<String, dynamic>>().map(_mapRow).toList();
      return CloudSuccess(list);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudDocument<T>>> fetchOne(String id) async {
    try {
      final row = await _client
          .from(collectionName)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        return CloudError<CloudDocument<T>>(
          message: 'Row not found',
          code: CloudErrorCode.notFound,
        );
      }
      return CloudSuccess(_mapRow(Map<String, dynamic>.from(row)));
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Stream<CloudResult<List<CloudDocument<T>>>> watch({CloudQuery? query}) {
    final base = _client.from(collectionName).stream(primaryKey: const ['id']);
    SupabaseStreamBuilder stream;
    if (query != null && query.filters.isNotEmpty) {
      final f = query.filters.first;
      if (query.filters.length > 1) {
        // Supabase Realtime stream supports a single server-side filter.
      }
      stream = switch (f) {
        WhereEqual(:final field, :final value) => base.eq(
          field,
          value as Object,
        ),
        WhereIn(:final field, :final values) => base.inFilter(
          field,
          values.map((e) => e as Object).toList(),
        ),
        WhereLessThan(:final field, :final value) => base.lt(
          field,
          value as Object,
        ),
        WhereGreaterThan(:final field, :final value) => base.gt(
          field,
          value as Object,
        ),
        WhereContains() => base,
      };
    } else {
      stream = base;
    }
    if (query?.orderBy != null) {
      stream = stream.order(query!.orderBy!, ascending: !query.descending);
    }
    if (query?.limit != null) {
      stream = stream.limit(query!.limit!);
    }
    return retryStream(
      stream.map(
        (rows) => CloudSuccess(
          rows.map((r) => _mapRow(Map<String, dynamic>.from(r))).toList(),
        ),
      ),
    );
  }

  @override
  Stream<CloudResult<CloudDocument<T>>> watchOne(String id) {
    return watch().asyncMap((result) async {
      switch (result) {
        case CloudSuccess<List<CloudDocument<T>>>(:final data):
          for (final d in data) {
            if (d.id == id) {
              return CloudSuccess<CloudDocument<T>>(d);
            }
          }
          return CloudError<CloudDocument<T>>(
            message: 'Document not found',
            code: CloudErrorCode.notFound,
          );
        case CloudError<List<CloudDocument<T>>>(:final message, :final code):
          return CloudError<CloudDocument<T>>(message: message, code: code);
      }
    });
  }

  @override
  Stream<CloudResult<CloudStreamEvent<T>>> watchEvents({
    CloudQuery? query,
  }) async* {
    Map<String, CloudDocument<T>>? previous;
    await for (final result in watch(query: query)) {
      switch (result) {
        case CloudSuccess<List<CloudDocument<T>>>(:final data):
          final next = {for (final d in data) d.id: d};
          if (previous == null) {
            for (final d in data) {
              yield CloudSuccess(CloudStreamAdded(d));
            }
          } else {
            for (final entry in next.entries) {
              final prior = previous[entry.key];
              if (prior == null) {
                yield CloudSuccess(CloudStreamAdded(entry.value));
              } else if (toJson(prior.data).toString() !=
                  toJson(entry.value.data).toString()) {
                yield CloudSuccess(CloudStreamModified(entry.value));
              }
            }
            for (final id in previous.keys) {
              if (!next.containsKey(id)) {
                yield CloudSuccess(CloudStreamRemoved(id));
              }
            }
          }
          previous = next;
        case CloudError<List<CloudDocument<T>>>(:final message, :final code):
          yield CloudError<CloudStreamEvent<T>>(message: message, code: code);
      }
    }
  }

  @override
  Future<CloudResult<CloudDocument<T>>> insert(T data) async {
    try {
      final row = toJson(data);
      row.remove('id');
      final inserted = await _client
          .from(collectionName)
          .insert(row)
          .select()
          .single();
      return CloudSuccess(_mapRow(Map<String, dynamic>.from(inserted)));
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudDocument<T>>> update(
    String id,
    Map<String, dynamic> partial,
  ) async {
    try {
      await _client.from(collectionName).update(partial).eq('id', id);
      return fetchOne(id);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> delete(String id) async {
    try {
      await _client.from(collectionName).delete().eq('id', id);
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> insertBatch(List<T> items) async {
    try {
      final rows = items.map((e) {
        final m = toJson(e);
        m.remove('id');
        return m;
      }).toList();
      await _client.from(collectionName).insert(rows);
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> updateBatch(
    Map<String, Map<String, dynamic>> updates,
  ) async {
    try {
      for (final e in updates.entries) {
        await _client.from(collectionName).update(e.value).eq('id', e.key);
      }
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> deleteBatch(List<String> ids) async {
    try {
      await _client.from(collectionName).delete().inFilter('id', ids);
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<R>> transaction<R>(
    Future<R> Function(CloudTransaction tx) handler,
  ) async {
    try {
      final tx = SupabaseTransaction(_client);
      final result = await handler(tx);
      await tx.flush();
      return CloudSuccess(result);
    } catch (e) {
      return mapException(e, code: CloudErrorCode.transactionFailed);
    }
  }
}

/// Client-side buffered writes — **not** a Postgres transaction. Use RPC for ACID.
final class SupabaseTransaction implements CloudTransaction {
  SupabaseTransaction(this._client);

  final SupabaseClient _client;
  final List<Future<void> Function()> _ops = [];

  Future<void> flush() async {
    for (final op in _ops) {
      await op();
    }
  }

  @override
  Future<CloudDocument<T>> get<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final row = await _client
        .from(collection)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) {
      throw StateError('Row not found: $collection/$id');
    }
    final m = Map<String, dynamic>.from(row);
    return CloudDocument(
      id: m['id']?.toString() ?? id,
      data: fromJson(m),
      createdAt: SupabaseCollection._readDate(
        m['created_at'] ?? m['createdAt'],
      ),
      updatedAt: SupabaseCollection._readDate(
        m['updated_at'] ?? m['updatedAt'],
      ),
    );
  }

  @override
  void set<T>(
    String collection,
    String id,
    T data,
    Map<String, dynamic> Function(T value) toJson,
  ) {
    final row = toJson(data);
    row.remove('id');
    _ops.add(() async {
      await _client.from(collection).upsert({...row, 'id': id});
    });
  }

  @override
  void update(String collection, String id, Map<String, dynamic> partial) {
    _ops.add(() async {
      await _client.from(collection).update(partial).eq('id', id);
    });
  }

  @override
  void delete(String collection, String id) {
    _ops.add(() async {
      await _client.from(collection).delete().eq('id', id);
    });
  }
}
