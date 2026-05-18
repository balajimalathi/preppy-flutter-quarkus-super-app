import 'package:meta/meta.dart';

/// One typed document returned from a cloud collection.
@immutable
final class CloudDocument<T> {
  const CloudDocument({
    required this.id,
    required this.data,
    this.createdAt,
    this.updatedAt,
  });

  /// Backend-specific unique identifier.
  final String id;

  /// Decoded document payload.
  final T data;

  /// Creation timestamp when the backend exposes it.
  final DateTime? createdAt;

  /// Last update timestamp when the backend exposes it.
  final DateTime? updatedAt;
}
