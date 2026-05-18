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

  /// Predicates applied to the query.
  final List<CloudFilter> filters;

  /// Field used for ordering results.
  final String? orderBy;

  /// Whether result ordering should be descending.
  final bool descending;

  /// Maximum number of results to return.
  final int? limit;

  /// Opaque cursor for pagination (adapter-specific, e.g. Firestore snapshot).
  final Object? startAfter;
}
