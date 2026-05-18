import 'package:meta/meta.dart';

/// How [CloudStorage.getDownloadUrl] should resolve a URL for an object path.
enum CloudUrlKind {
  /// Each adapter keeps its previous behavior (backward compatible).
  legacy,

  /// Stable URL without time-limited signing where the backend supports it.
  /// For private buckets this may still 403 at fetch time.
  public,

  /// Time-limited signed URL; uses [CloudDownloadUrlRequest.expiresIn].
  signed,
}

@immutable
/// Options controlling how a download URL should be resolved.
final class CloudDownloadUrlRequest {
  const CloudDownloadUrlRequest({
    this.kind = CloudUrlKind.legacy,
    this.expiresIn = const Duration(hours: 1),
  });

  /// Preferred URL resolution mode.
  final CloudUrlKind kind;

  /// Used when [kind] is [CloudUrlKind.signed].
  final Duration expiresIn;
}
