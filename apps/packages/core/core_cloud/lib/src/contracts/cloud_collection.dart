import '../models/cloud_document.dart';
import '../models/cloud_query.dart';
import '../models/cloud_result.dart';
import '../models/cloud_stream_event.dart';
import 'cloud_transaction.dart';

/// Typed document collection — implemented per backend inside this package.
abstract interface class CloudCollection<T> {
  Future<CloudResult<List<CloudDocument<T>>>> fetch({CloudQuery? query});

  Future<CloudResult<CloudDocument<T>>> fetchOne(String id);

  Stream<CloudResult<List<CloudDocument<T>>>> watch({CloudQuery? query});

  Stream<CloudResult<CloudDocument<T>>> watchOne(String id);

  /// Granular change events. Fidelity varies by backend; see package README.
  Stream<CloudResult<CloudStreamEvent<T>>> watchEvents({CloudQuery? query});

  Future<CloudResult<CloudDocument<T>>> insert(T data);

  Future<CloudResult<CloudDocument<T>>> update(
    String id,
    Map<String, dynamic> partial,
  );

  Future<CloudResult<CloudUnit>> delete(String id);

  Future<CloudResult<CloudUnit>> insertBatch(List<T> items);

  Future<CloudResult<CloudUnit>> updateBatch(
    Map<String, Map<String, dynamic>> updates,
  );

  Future<CloudResult<CloudUnit>> deleteBatch(List<String> ids);

  Future<CloudResult<R>> transaction<R>(
    Future<R> Function(CloudTransaction tx) handler,
  );
}
