import 'package:meta/meta.dart';

@immutable
final class CloudDocument<T> {
  const CloudDocument({
    required this.id,
    required this.data,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final T data;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
