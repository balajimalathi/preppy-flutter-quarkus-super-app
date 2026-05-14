import 'package:meta/meta.dart';

import '../../models/cloud_download_url_request.dart';

/// Connection and URL policy for S3-compatible object storage (AWS S3, R2,
/// MinIO, RustFS, etc.).
///
/// **Security:** embedding long-lived access keys in client apps is risky.
/// Prefer short-lived credentials from your backend or presigned flows in production.
@immutable
final class S3StorageConfig {
  const S3StorageConfig({
    required this.endpoint,
    required this.accessKey,
    required this.secretKey,
    required this.region,
    required this.bucket,
    this.port,
    this.sessionToken,
    this.useSSL = true,
    this.enablePathStyle = false,
    this.publicBaseUrl,
    this.defaultSignedExpiry = const Duration(hours: 1),
    this.uploadResultUrlKind = CloudUrlKind.signed,
  });

  /// API hostname only (no scheme), e.g. `s3.us-east-1.amazonaws.com` or `localhost`.
  final String endpoint;

  final String accessKey;

  final String secretKey;

  /// Optional STS session token for temporary credentials.
  final String? sessionToken;

  /// AWS-style region, or `auto` for providers such as Cloudflare R2.
  final String region;

  final String bucket;

  /// Non-default HTTPS port (e.g. MinIO `9000`). Omit for 80/443.
  final int? port;

  final bool useSSL;

  /// Use path-style URLs (`host/bucket/key`). Required for many self-hosted gateways.
  final bool enablePathStyle;

  /// When set, [CloudUrlKind.public] URLs are built as `publicBaseUrl` + object key.
  /// Omit to synthesize a public URL from [endpoint], [bucket], and path style.
  final String? publicBaseUrl;

  /// Default expiry for presigned GET when [CloudDownloadUrlRequest.kind] is [CloudUrlKind.legacy].
  final Duration defaultSignedExpiry;

  /// Controls the URL returned from [S3CompatibleStorageAdapter.upload].
  /// [CloudUrlKind.legacy] is treated like [CloudUrlKind.signed] for uploads.
  final CloudUrlKind uploadResultUrlKind;
}
