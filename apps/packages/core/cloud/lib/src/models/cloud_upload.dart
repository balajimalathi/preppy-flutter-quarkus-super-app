import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
/// Input payload for uploading a single object to [CloudStorage].
final class CloudUploadConfig {
  const CloudUploadConfig({
    required this.path,
    required this.bytes,
    required this.mimeType,
    this.metadata,
  });

  /// Backend-relative object path.
  final String path;

  /// Binary file contents.
  final Uint8List bytes;

  /// MIME type sent with the upload.
  final String mimeType;

  /// Optional backend-specific object metadata.
  final Map<String, String>? metadata;
}

@immutable
/// Result metadata returned after a successful upload.
final class CloudUploadResult {
  const CloudUploadResult({
    required this.url,
    required this.path,
    required this.sizeBytes,
  });

  /// Downloadable URL returned by the backend when available.
  final String url;

  /// Final stored object path.
  final String path;

  /// Number of uploaded bytes.
  final int sizeBytes;
}
