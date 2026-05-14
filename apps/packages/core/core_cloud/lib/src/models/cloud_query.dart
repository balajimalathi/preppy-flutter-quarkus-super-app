import 'cloud_filter.dart';

/// Portable query description mapped per adapter.
final class CloudQuery {
  const CloudQuery({
    this.filters = const [],
    this.orderBy,
    this.descending = false,
    this.limit,
    this.startAfter,
  });

  final List<CloudFilter> filters;
  final String? orderBy;
  final bool descending;
  final int? limit;

  /// Opaque cursor for pagination (adapter-specific, e.g. Firestore snapshot).
  final Object? startAfter;
}
