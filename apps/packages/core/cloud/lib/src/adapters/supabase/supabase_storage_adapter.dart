import 'package:supabase_flutter/supabase_flutter.dart';

import '../../base/base_cloud_storage.dart';
import '../../models/cloud_download_url_request.dart';
import '../../models/cloud_result.dart';
import '../../models/cloud_upload.dart';

final class SupabaseStorageAdapter extends BaseCloudStorage {
  SupabaseStorageAdapter({required SupabaseClient client, required this.bucket})
    : _client = client;

  final SupabaseClient _client;
  final String bucket;

  @override
  Future<CloudResult<CloudUploadResult>> upload(
    CloudUploadConfig config,
  ) async {
    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            config.path,
            config.bytes,
            fileOptions: FileOptions(
              contentType: config.mimeType,
              upsert: true,
            ),
          );
      final url = _client.storage.from(bucket).getPublicUrl(config.path);
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
      final from = _client.storage.from(bucket);
      switch (request.kind) {
        case CloudUrlKind.legacy:
        case CloudUrlKind.signed:
          final seconds = request.kind == CloudUrlKind.legacy
              ? 3600
              : request.expiresIn.inSeconds.clamp(1, 31536000);
          final url = await from.createSignedUrl(path, seconds);
          return CloudSuccess(url);
        case CloudUrlKind.public:
          return CloudSuccess(from.getPublicUrl(path));
      }
    } catch (e) {
      return mapStorageException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> deleteFile(String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapStorageException(e);
    }
  }

  @override
  Stream<double> uploadProgress(CloudUploadConfig config) async* {
    yield 0;
    final r = await upload(config);
    yield switch (r) {
      CloudSuccess() => 1.0,
      CloudError() => 0.0,
    };
  }
}
