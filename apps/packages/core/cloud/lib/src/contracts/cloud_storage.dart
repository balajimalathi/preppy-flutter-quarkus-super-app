import '../models/cloud_download_url_request.dart';
import '../models/cloud_result.dart';
import '../models/cloud_upload.dart';

/// Object/file storage (images, attachments).
abstract interface class CloudStorage {
  /// Uploads the object described by [config].
  Future<CloudResult<CloudUploadResult>> upload(CloudUploadConfig config);

  /// Resolves a URL for [path]. Use [request] to request public vs signed URLs
  /// where the backend supports it; default preserves each adapter’s legacy behavior.
  Future<CloudResult<String>> getDownloadUrl(
    String path, {
    CloudDownloadUrlRequest request = const CloudDownloadUrlRequest(),
  });

  /// Deletes the object stored at [path].
  Future<CloudResult<CloudUnit>> deleteFile(String path);

  /// Emits 0.0–1.0 progress where the backend supports it.
  Stream<double> uploadProgress(CloudUploadConfig config);
}
