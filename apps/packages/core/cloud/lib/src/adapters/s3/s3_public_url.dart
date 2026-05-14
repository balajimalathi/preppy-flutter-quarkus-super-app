import 'package:meta/meta.dart';

import 's3_storage_config.dart';

/// Builds deterministic “public” object URLs without calling the API.
@immutable
final class S3PublicUrl {
  const S3PublicUrl._();

  /// Joins [base] and [objectKey] with a single slash boundary.
  static String joinBaseAndKey(String base, String objectKey) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final k = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
    return '$b/$k';
  }

  /// Encodes each `/`-separated segment of an S3 object key for use in a path.
  static String encodeObjectPath(String objectKey) {
    return objectKey
        .split('/')
        .where((s) => s.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');
  }

  /// Public GET URL (no SigV4). Callers must ensure the object is actually public.
  static String build({
    required S3StorageConfig config,
    required String objectKey,
  }) {
    final encoded = encodeObjectPath(objectKey);
    final base = config.publicBaseUrl;
    if (base != null && base.isNotEmpty) {
      return joinBaseAndKey(base, objectKey);
    }
    final scheme = config.useSSL ? 'https' : 'http';
    final portSuffix =
        config.port != null && !_isDefaultPort(scheme, config.port!)
        ? ':${config.port}'
        : '';
    if (config.enablePathStyle) {
      return '$scheme://${config.endpoint}$portSuffix/${config.bucket}/$encoded';
    }
    return '$scheme://${config.bucket}.${config.endpoint}$portSuffix/$encoded';
  }

  static bool _isDefaultPort(String scheme, int port) {
    return (scheme == 'https' && port == 443) ||
        (scheme == 'http' && port == 80);
  }
}
