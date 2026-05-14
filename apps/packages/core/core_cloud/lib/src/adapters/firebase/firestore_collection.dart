import 'package:cloud_firestore/cloud_firestore.dart';

import '../../base/base_cloud_collection.dart';
import '../../contracts/cloud_collection.dart';
import '../../contracts/cloud_transaction.dart';
import '../../models/cloud_document.dart';
import '../../models/cloud_filter.dart';
import '../../models/cloud_query.dart';
import '../../models/cloud_result.dart';
import '../../models/cloud_stream_event.dart';

final class FirestoreCollection<T> extends BaseCloudCollection<T>
    implements CloudCollection<T> {
  FirestoreCollection({
    required super.collectionName,
    required super.fromJson,
    required super.toJson,
    required CollectionReference<Map<String, dynamic>> reference,
  }) : _ref = reference;

  final CollectionReference<Map<String, dynamic>> _ref;
  FirebaseFirestore get _firestore => _ref.firestore;

  @override
  CloudResult<R> mapException<R>(
    Object error, {
    CloudErrorCode code = CloudErrorCode.unknown,
  }) {
    if (error is FirebaseException) {
      final mapped = switch (error.code) {
        'permission-denied' => CloudErrorCode.permissionDenied,
        'not-found' => CloudErrorCode.notFound,
        'unavailable' || 'deadline-exceeded' => CloudErrorCode.networkError,
        _ => CloudErrorCode.unknown,
      };
      return CloudError(message: error.message ?? error.code, code: mapped);
    }
    return super.mapException(error, code: code);
  }

  CloudDocument<T> _mapDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final json = Map<String, dynamic>.from(doc.data());
    json['id'] = doc.id;
    return CloudDocument(
      id: doc.id,
      data: fromJson(json),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  CloudDocument<T> _mapDocSnap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing document ${doc.id}');
    }
    final json = Map<String, dynamic>.from(data);
    json['id'] = doc.id;
    return CloudDocument(
      id: doc.id,
      data: fromJson(json),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Query<Map<String, dynamic>> _applyQuery(
    Query<Map<String, dynamic>> q,
    CloudQuery query,
  ) {
    var out = q;
    for (final f in query.filters) {
      out = switch (f) {
        WhereEqual(:final field, :final value) => out.where(
          field,
          isEqualTo: value,
        ),
        WhereIn(:final field, :final values) => out.where(
          field,
          whereIn: values,
        ),
        WhereLessThan(:final field, :final value) => out.where(
          field,
          isLessThan: value,
        ),
        WhereGreaterThan(:final field, :final value) => out.where(
          field,
          isGreaterThan: value,
        ),
        WhereContains(:final field, :final value) =>
          out
              .where(field, isGreaterThanOrEqualTo: value)
              .where(field, isLessThan: '$value\uf8ff'),
      };
    }
    if (query.orderBy != null) {
      out = out.orderBy(query.orderBy!, descending: query.descending);
    }
    if (query.limit != null) {
      out = out.limit(query.limit!);
    }
    if (query.startAfter != null) {
      final cursor = query.startAfter;
      if (cursor is DocumentSnapshot<Map<String, dynamic>>) {
        out = out.startAfterDocument(cursor);
      }
    }
    return out;
  }

  @override
  Future<CloudResult<List<CloudDocument<T>>>> fetch({CloudQuery? query}) async {
    try {
      Query<Map<String, dynamic>> q = _ref;
      if (query != null) {
        q = _applyQuery(q, query);
      }
      final snap = await q.get();
      return CloudSuccess(snap.docs.map(_mapDoc).toList());
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudDocument<T>>> fetchOne(String id) async {
    try {
      final doc = await _ref.doc(id).get();
      if (!doc.exists) {
        return CloudError<CloudDocument<T>>(
          message: 'Document not found',
          code: CloudErrorCode.notFound,
        );
      }
      return CloudSuccess(_mapDocSnap(doc));
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Stream<CloudResult<List<CloudDocument<T>>>> watch({CloudQuery? query}) {
    Query<Map<String, dynamic>> q = _ref;
    if (query != null) {
      q = _applyQuery(q, query);
    }
    return retryStream(
      q.snapshots().map(
        (snap) => CloudSuccess(snap.docs.map(_mapDoc).toList()),
      ),
    );
  }

  @override
  Stream<CloudResult<CloudDocument<T>>> watchOne(String id) {
    return retryStream(
      _ref.doc(id).snapshots().map((snap) {
        if (!snap.exists) {
          return CloudError<CloudDocument<T>>(
            message: 'Document not found',
            code: CloudErrorCode.notFound,
          );
        }
        return CloudSuccess(_mapDocSnap(snap));
      }),
    );
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
              } else if (_docPayloadChanged(prior, entry.value)) {
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

  bool _docPayloadChanged(CloudDocument<T> a, CloudDocument<T> b) {
    return toJson(a.data).toString() != toJson(b.data).toString();
  }

  @override
  Future<CloudResult<CloudDocument<T>>> insert(T data) async {
    try {
      final doc = _ref.doc();
      final json = toJson(data);
      json.removeWhere((k, v) => k == 'id');
      await doc.set(json);
      final withId = _mergeId(data, doc.id);
      return CloudSuccess(
        CloudDocument(
          id: doc.id,
          data: withId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return mapException(e);
    }
  }

  T _mergeId(T data, String id) {
    final j = toJson(data);
    j['id'] = id;
    return fromJson(j);
  }

  @override
  Future<CloudResult<CloudDocument<T>>> update(
    String id,
    Map<String, dynamic> partial,
  ) async {
    try {
      await _ref.doc(id).update(partial);
      final fresh = await fetchOne(id);
      return switch (fresh) {
        CloudSuccess() => fresh,
        CloudError() => fresh,
      };
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> delete(String id) async {
    try {
      await _ref.doc(id).delete();
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> insertBatch(List<T> items) async {
    try {
      final batch = _firestore.batch();
      for (final item in items) {
        final doc = _ref.doc();
        final json = toJson(item);
        json.removeWhere((k, v) => k == 'id');
        batch.set(doc, json);
      }
      await batch.commit();
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
      final batch = _firestore.batch();
      for (final e in updates.entries) {
        batch.update(_ref.doc(e.key), e.value);
      }
      await batch.commit();
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> deleteBatch(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_ref.doc(id));
      }
      await batch.commit();
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
      final result = await _firestore.runTransaction((fsTx) async {
        final tx = FirestoreTransaction(fsTx, _firestore);
        return handler(tx);
      });
      return CloudSuccess(result);
    } catch (e) {
      return mapException(e, code: CloudErrorCode.transactionFailed);
    }
  }
}

final class FirestoreTransaction implements CloudTransaction {
  FirestoreTransaction(this._tx, this._firestore);

  final Transaction _tx;
  final FirebaseFirestore _firestore;

  @override
  Future<CloudDocument<T>> get<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final snap = await _tx.get(_firestore.collection(collection).doc(id));
    if (!snap.exists || snap.data() == null) {
      throw StateError('Document not found: $collection/$id');
    }
    final json = Map<String, dynamic>.from(snap.data()!);
    json['id'] = snap.id;
    return CloudDocument(
      id: snap.id,
      data: fromJson(json),
      createdAt: FirestoreCollection._readDate(json['createdAt']),
      updatedAt: FirestoreCollection._readDate(json['updatedAt']),
    );
  }

  @override
  void set<T>(
    String collection,
    String id,
    T data,
    Map<String, dynamic> Function(T value) toJson,
  ) {
    final json = toJson(data);
    json.removeWhere((k, v) => k == 'id');
    _tx.set(_firestore.collection(collection).doc(id), json);
  }

  @override
  void update(String collection, String id, Map<String, dynamic> partial) {
    _tx.update(_firestore.collection(collection).doc(id), partial);
  }

  @override
  void delete(String collection, String id) {
    _tx.delete(_firestore.collection(collection).doc(id));
  }
}
