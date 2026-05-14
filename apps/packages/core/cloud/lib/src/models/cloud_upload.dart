import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
final class CloudUploadConfig {
  const CloudUploadConfig({
    required this.path,
    required this.bytes,
    required this.mimeType,
    this.metadata,
  });

  final String path;
  final Uint8List bytes;
  final String mimeType;
  final Map<String, String>? metadata;
}

@immutable
final class CloudUploadResult {
  const CloudUploadResult({
    required this.url,
    required this.path,
    required this.sizeBytes,
  });

  final String url;
  final String path;
  final int sizeBytes;
}
