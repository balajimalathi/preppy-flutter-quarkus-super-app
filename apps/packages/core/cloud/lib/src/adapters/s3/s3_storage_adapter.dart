import 'dart:async';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

import '../../base/base_cloud_storage.dart';
import '../../models/cloud_download_url_request.dart';
import '../../models/cloud_result.dart';
import '../../models/cloud_upload.dart';
import 's3_public_url.dart';
import 's3_storage_config.dart';

final class S3HttpException implements Exception {
  S3HttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'S3HttpException($statusCode): $body';
}

/// S3-compatible storage using SigV4 ([aws_signature_v4]) over HTTP.
final class S3CompatibleStorageAdapter extends BaseCloudStorage {
  S3CompatibleStorageAdapter({required S3StorageConfig config})
    : _config = config,
      _signer = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(
          AWSCredentials(
            config.accessKey,
            config.secretKey,
            config.sessionToken,
          ),
        ),
      );

  final S3StorageConfig _config;
  final AWSSigV4Signer _signer;

  static final _s3UnsignedPayload = S3ServiceConfiguration(signPayload: false);

  Uri _objectUri(String objectKey) {
    final encoded = S3PublicUrl.encodeObjectPath(objectKey);
    if (_config.enablePathStyle) {
      return Uri(
        scheme: _config.useSSL ? 'https' : 'http',
        host: _config.endpoint,
        port: _config.port,
        path: '/${_config.bucket}/$encoded',
      );
    }
    return Uri(
      scheme: _config.useSSL ? 'https' : 'http',
      host: '${_config.bucket}.${_config.endpoint}',
      port: _config.port,
      path: '/$encoded',
    );
  }

  Duration _clipExpiry(Duration d) {
    const min = Duration(seconds: 1);
    const max = Duration(days: 7);
    if (d < min) {
      return min;
    }
    if (d > max) {
      return max;
    }
    return d;
  }

  Future<String> _presignedGet(String objectKey, Duration expiresIn) async {
    final uri = _objectUri(objectKey);
    final req = AWSHttpRequest.get(uri);
    final signedUri = await _signer.presign(
      req,
      credentialScope: AWSCredentialScope(
        region: _config.region,
        service: AWSService.s3,
      ),
      serviceConfiguration: _s3UnsignedPayload,
      expiresIn: _clipExpiry(expiresIn),
    );
    return signedUri.toString();
  }

  Future<void> _putObject(CloudUploadConfig config) async {
    final uri = _objectUri(config.path);
    final headers = <String, String>{AWSHeaders.contentType: config.mimeType};
    final meta = config.metadata;
    if (meta != null) {
      for (final e in meta.entries) {
        final safe = e.key.toLowerCase().replaceAll(RegExp('[^a-z0-9-]'), '_');
        headers['x-amz-meta-$safe'] = e.value;
      }
    }
    final req = AWSHttpRequest.put(uri, body: config.bytes, headers: headers);
    final signed = await _signer.sign(
      req,
      credentialScope: AWSCredentialScope(
        region: _config.region,
        service: AWSService.s3,
      ),
      serviceConfiguration: _s3UnsignedPayload,
    );
    final resp = await signed.send().response;
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return;
    }
    final body = await _safeDecode(resp);
    throw S3HttpException(resp.statusCode, body);
  }

  Future<void> _deleteObject(String path) async {
    final uri = _objectUri(path);
    final req = AWSHttpRequest.delete(uri);
    final signed = await _signer.sign(
      req,
      credentialScope: AWSCredentialScope(
        region: _config.region,
        service: AWSService.s3,
      ),
      serviceConfiguration: _s3UnsignedPayload,
    );
    final resp = await signed.send().response;
    if (resp.statusCode == 204 || resp.statusCode == 200) {
      return;
    }
    final body = await _safeDecode(resp);
    throw S3HttpException(resp.statusCode, body);
  }

  Future<String> _urlAfterUpload(String path) async {
    final kind = switch (_config.uploadResultUrlKind) {
      CloudUrlKind.legacy => CloudUrlKind.signed,
      CloudUrlKind.public => CloudUrlKind.public,
      CloudUrlKind.signed => CloudUrlKind.signed,
    };
    return switch (kind) {
      CloudUrlKind.public => S3PublicUrl.build(
        config: _config,
        objectKey: path,
      ),
      CloudUrlKind.signed => _presignedGet(path, _config.defaultSignedExpiry),
      CloudUrlKind.legacy => throw StateError('unreachable'),
    };
  }

  static Future<String> _safeDecode(AWSBaseHttpResponse resp) async {
    try {
      return await resp.decodeBody();
    } catch (_) {
      return '';
    }
  }

  @override
  CloudResult<R> mapStorageException<R>(Object error) {
    if (error is S3HttpException) {
      final code = switch (error.statusCode) {
        404 => CloudErrorCode.notFound,
        403 => CloudErrorCode.permissionDenied,
        _ => CloudErrorCode.storageError,
      };
      return CloudError<R>(
        message: error.body.isEmpty ? '${error.statusCode}' : error.body,
        code: code,
      );
    }
    return super.mapStorageException(error);
  }

  @override
  Future<CloudResult<CloudUploadResult>> upload(
    CloudUploadConfig config,
  ) async {
    try {
      await _putObject(config);
      final url = await _urlAfterUpload(config.path);
      return CloudSuccess(
        CloudUploadResult(
          url: url,
          path: config.path,
          sizeBytes: config.bytes.length,
        ),
      );
    } catch (e) {
      return mapStorageException(e);
    }
  }

  @override
  Future<CloudResult<String>> getDownloadUrl(
    String path, {
    CloudDownloadUrlRequest request = const CloudDownloadUrlRequest(),
  }) async {
    try {
      switch (request.kind) {
        case CloudUrlKind.public:
          return CloudSuccess(
            S3PublicUrl.build(config: _config, objectKey: path),
          );
        case CloudUrlKind.signed:
          final u = await _presignedGet(path, request.expiresIn);
          return CloudSuccess(u);
        case CloudUrlKind.legacy:
          final u = await _presignedGet(path, _config.defaultSignedExpiry);
          return CloudSuccess(u);
      }
    } catch (e) {
      return mapStorageException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> deleteFile(String path) async {
    try {
      await _deleteObject(path);
      return const CloudSuccess(cloudUnit);
    } catch (e) {
      return mapStorageException(e);
    }
  }

  @override
  Stream<double> uploadProgress(CloudUploadConfig config) async* {
    yield 0;
    try {
      await _putObject(config);
      yield 1;
    } catch (_) {
      yield 0;
    }
  }
}
