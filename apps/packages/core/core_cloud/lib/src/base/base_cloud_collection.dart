import '../models/cloud_result.dart';

/// Shared error mapping and stream helpers for collection adapters.
base class BaseCloudCollection<T> {
  BaseCloudCollection({
    required this.collectionName,
    required this.fromJson,
    required this.toJson,
  });

  final String collectionName;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T value) toJson;

  CloudResult<R> mapException<R>(
    Object error, {
    CloudErrorCode code = CloudErrorCode.unknown,
  }) {
    return CloudError<R>(message: error.toString(), code: code);
  }

  /// Pass-through by default; adapters may wrap with resubscribe logic.
  Stream<CloudResult<S>> retryStream<S>(Stream<CloudResult<S>> source) =>
      source;
}
