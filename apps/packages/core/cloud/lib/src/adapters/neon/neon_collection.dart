import 'dart:convert';

import 'package:postgres/postgres.dart';

import '../../base/base_cloud_collection.dart';
import '../../contracts/cloud_collection.dart';
import '../../contracts/cloud_transaction.dart';
import '../../models/cloud_document.dart';
import '../../models/cloud_filter.dart';
import '../../models/cloud_query.dart';
import '../../models/cloud_result.dart';
import '../../models/cloud_stream_event.dart';

/// Postgres-backed collection using `id TEXT` + `data JSONB` columns.
///
/// [watch] uses polling only (no LISTEN). Prefer server-mediated access from
/// mobile clients — see package README.
final class NeonCollection<T> extends BaseCloudCollection<T>
    implements CloudCollection<T> {
  NeonCollection({
    required super.collectionName,
    required super.fromJson,
    required super.toJson,
    required Connection connection,
    required this.pollInterval,
  }) : _connection = connection;

  final Connection _connection;
  final Duration pollInterval;

  String get _quotedTable =>
      '"${NeonCollection._assertSafeIdent(collectionName)}"';

  static String _assertSafeIdent(String name) {
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
      throw ArgumentError.value(name, 'collectionName', 'Unsafe table name');
    }
    return name;
  }

  @override
  CloudResult<R> mapException<R>(
    Object error, {
    CloudErrorCode code = CloudErrorCode.unknown,
  }) {
    return CloudError(message: error.toString(), code: code);
  }

  CloudDocument<T> _mapRow(ResultRow row) => neonMapRow(row, fromJson);

  static String? _safeOrderBy(String? raw) {
    if (raw == null) return null;
    final snake = switch (raw) {
      'createdAt' => 'created_at',
      'updatedAt' => 'updated_at',
      _ => raw,
    };
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(snake)) {
      throw UnsupportedError('Unsafe orderBy: $raw');
    }
    const allow = {'id', 'data'};
    if (!allow.contains(snake)) {
      throw UnsupportedError('Neon orderBy not supported: $raw');
    }
    return snake;
  }

  Map<String, Object?> _equalityPayload(CloudQuery? query) {
    if (query == null || query.filters.isEmpty) {
      return const {};
    }
    final m = <String, Object?>{};
    for (final f in query.filters) {
      switch (f) {
        case WhereEqual(:final field, :final value):
          m[field] = value;
        default:
          throw UnsupportedError('Neon adapter filter not supported: $f');
      }
    }
    return m;
  }

  @override
  Future<CloudResult<List<CloudDocument<T>>>> fetch({CloudQuery? query}) async {
    try {
      final payload = _equalityPayload(query);
      final sql = StringBuffer('SELECT id, data FROM $_quotedTable');
      final Map<String, Object?> params = {};
      if (payload.isNotEmpty) {
        sql.write(' WHERE data @> @match::jsonb');
        params['match'] = TypedValue(
          Type.jsonb,
          jsonDecode(jsonEncode(payload)) as Map<Object?, Object?>,
        );
      }
      if (query?.orderBy != null) {
        final col = _safeOrderBy(query!.orderBy);
        sql.write(' ORDER BY $col ${query.descending ? 'DESC' : 'ASC'}');
      }
      if (query?.limit != null) {
        sql.write(' LIMIT ${query!.limit}');
      }
      final result = await _connection.execute(
        Sql.named(sql.toString()),
        parameters: params,
      );
      return CloudSuccess(result.map(_mapRow).toList());
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudDocument<T>>> fetchOne(String id) async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT id, data FROM $_quotedTable WHERE id = @id'),
        parameters: {'id': id},
      );
      if (result.isEmpty) {
        return CloudError<CloudDocument<T>>(
          message: 'Row not found',
          code: CloudErrorCode.notFound,
        );
      }
      return CloudSuccess(_mapRow(result.first));
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Stream<CloudResult<List<CloudDocument<T>>>> watch({CloudQuery? query}) {
    return retryStream(
      Stream<void>.periodic(pollInterval).asyncMap((_) => fetch(query: query)),
    );
  }

  @override
  Stream<CloudResult<CloudDocument<T>>> watchOne(String id) {
    return watch().asyncMap((r) async {
      switch (r) {
        case CloudSuccess<List<CloudDocument<T>>>(:final data):
          for (final d in data) {
            if (d.id == id) return CloudSuccess<CloudDocument<T>>(d);
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
      final rowJson = Map<String, dynamic>.from(toJson(data));
      final id = rowJson.remove('id')?.toString() ?? _randomId();
      final dataJson = TypedValue(
        Type.jsonb,
        jsonDecode(jsonEncode(rowJson)) as Map<Object?, Object?>,
      );
      await _connection.execute(
        Sql.named(
          'INSERT INTO $_quotedTable (id, data) VALUES (@id, @data) '
          'ON CONFLICT (id) DO UPDATE SET data = EXCLUDED.data '
          'RETURNING id, data',
        ),
        parameters: {'id': id, 'data': dataJson},
      );
      return fetchOne(id);
    } catch (e) {
      return mapException(e);
    }
  }

  String _randomId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Future<CloudResult<CloudDocument<T>>> update(
    String id,
    Map<String, dynamic> partial,
  ) async {
    try {
      final patch = TypedValue(
        Type.jsonb,
        jsonDecode(jsonEncode(partial)) as Map<Object?, Object?>,
      );
      await _connection.execute(
        Sql.named(
          'UPDATE $_quotedTable SET data = data || @patch::jsonb WHERE id = @id',
        ),
        parameters: {'id': id, 'patch': patch},
      );
      return fetchOne(id);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> delete(String id) async {
    try {
      await _connection.execute(
        Sql.named('DELETE FROM $_quotedTable WHERE id = @id'),
        parameters: {'id': id},
      );
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> insertBatch(List<T> items) async {
    try {
      await _connection.runTx((s) async {
        for (final item in items) {
          final rowJson = Map<String, dynamic>.from(toJson(item));
          final id = rowJson.remove('id')?.toString() ?? _randomId();
          final dataJson = TypedValue(
            Type.jsonb,
            jsonDecode(jsonEncode(rowJson)) as Map<Object?, Object?>,
          );
          await s.execute(
            Sql.named(
              'INSERT INTO $_quotedTable (id, data) VALUES (@id, @data)',
            ),
            parameters: {'id': id, 'data': dataJson},
          );
        }
      });
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
      await _connection.runTx((s) async {
        for (final e in updates.entries) {
          final patch = TypedValue(
            Type.jsonb,
            jsonDecode(jsonEncode(e.value)) as Map<Object?, Object?>,
          );
          await s.execute(
            Sql.named(
              'UPDATE $_quotedTable SET data = data || @patch::jsonb WHERE id = @id',
            ),
            parameters: {'id': e.key, 'patch': patch},
          );
        }
      });
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> deleteBatch(List<String> ids) async {
    try {
      await _connection.execute(
        Sql.named('DELETE FROM $_quotedTable WHERE id = ANY(@ids)'),
        parameters: {'ids': TypedValue(Type.textArray, ids)},
      );
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
      late R out;
      await _connection.runTx((s) async {
        final tx = NeonTransaction(s);
        out = await handler(tx);
        await tx.flush();
      });
      return CloudSuccess(out);
    } catch (e) {
      return mapException(e, code: CloudErrorCode.transactionFailed);
    }
  }
}

CloudDocument<T> neonMapRow<T>(
  ResultRow row,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final map = row.toColumnMap();
  final id = map['id']?.toString() ?? '';
  final raw = map['data'];
  final Map<String, dynamic> json;
  if (raw is Map<String, dynamic>) {
    json = Map<String, dynamic>.from(raw);
  } else if (raw is String) {
    json = (jsonDecode(raw) as Map).cast<String, dynamic>();
  } else {
    json = <String, dynamic>{};
  }
  json['id'] = id;
  return CloudDocument(
    id: id,
    data: fromJson(json),
    createdAt: null,
    updatedAt: null,
  );
}

final class NeonTransaction implements CloudTransaction {
  NeonTransaction(this._session);

  final TxSession _session;
  final List<Future<void> Function()> _ops = [];

  Future<void> flush() async {
    for (final op in _ops) {
      await op();
    }
  }

  String _qTable(String collection) =>
      '"${NeonCollection._assertSafeIdent(collection)}"';

  @override
  Future<CloudDocument<T>> get<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final result = await _session.execute(
      Sql.named('SELECT id, data FROM ${_qTable(collection)} WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) {
      throw StateError('Row not found: $collection/$id');
    }
    return neonMapRow(result.first, fromJson);
  }

  @override
  void set<T>(
    String collection,
    String id,
    T data,
    Map<String, dynamic> Function(T value) toJson,
  ) {
    final rowJson = Map<String, dynamic>.from(toJson(data));
    rowJson.remove('id');
    final dataJson = TypedValue(
      Type.jsonb,
      jsonDecode(jsonEncode(rowJson)) as Map<Object?, Object?>,
    );
    _ops.add(() async {
      await _session.execute(
        Sql.named(
          'INSERT INTO ${_qTable(collection)} (id, data) VALUES (@id, @data) '
          'ON CONFLICT (id) DO UPDATE SET data = EXCLUDED.data',
        ),
        parameters: {'id': id, 'data': dataJson},
      );
    });
  }

  @override
  void update(String collection, String id, Map<String, dynamic> partial) {
    final patch = TypedValue(
      Type.jsonb,
      jsonDecode(jsonEncode(partial)) as Map<Object?, Object?>,
    );
    _ops.add(() async {
      await _session.execute(
        Sql.named(
          'UPDATE ${_qTable(collection)} SET data = data || @patch::jsonb WHERE id = @id',
        ),
        parameters: {'id': id, 'patch': patch},
      );
    });
  }

  @override
  void delete(String collection, String id) {
    _ops.add(() async {
      await _session.execute(
        Sql.named('DELETE FROM ${_qTable(collection)} WHERE id = @id'),
        parameters: {'id': id},
      );
    });
  }
}
