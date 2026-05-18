import '../models/cloud_document.dart';
import '../models/cloud_query.dart';
import '../models/cloud_result.dart';
import '../models/cloud_stream_event.dart';
import 'cloud_transaction.dart';

/// Typed document collection — implemented per backend inside this package.
abstract interface class CloudCollection<T> {
  /// Fetches all documents matching [query], or the backend default ordering when omitted.
  Future<CloudResult<List<CloudDocument<T>>>> fetch({CloudQuery? query});

  /// Fetches a single document by [id].
  Future<CloudResult<CloudDocument<T>>> fetchOne(String id);

  /// Watches query results as a full list snapshot stream.
  Stream<CloudResult<List<CloudDocument<T>>>> watch({CloudQuery? query});

  /// Watches a single document by [id].
  Stream<CloudResult<CloudDocument<T>>> watchOne(String id);

  /// Granular change events. Fidelity varies by backend; see package README.
  Stream<CloudResult<CloudStreamEvent<T>>> watchEvents({CloudQuery? query});

  /// Inserts a new document and returns the stored record with its generated id.
  Future<CloudResult<CloudDocument<T>>> insert(T data);

  /// Applies a partial update to the document identified by [id].
  Future<CloudResult<CloudDocument<T>>> update(
    String id,
    Map<String, dynamic> partial,
  );

  /// Deletes a document by [id].
  Future<CloudResult<CloudUnit>> delete(String id);

  /// Inserts multiple documents using the backend's batch semantics.
  Future<CloudResult<CloudUnit>> insertBatch(List<T> items);

  /// Applies multiple partial updates keyed by document id.
  Future<CloudResult<CloudUnit>> updateBatch(
    Map<String, Map<String, dynamic>> updates,
  );

  /// Deletes multiple documents by id.
  Future<CloudResult<CloudUnit>> deleteBatch(List<String> ids);

  /// Runs [handler] inside the backend's transaction abstraction when supported.
  Future<CloudResult<R>> transaction<R>(
    Future<R> Function(CloudTransaction tx) handler,
  );
}
