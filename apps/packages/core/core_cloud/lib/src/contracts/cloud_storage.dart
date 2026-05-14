import '../models/cloud_result.dart';
import '../models/cloud_upload.dart';

/// Object/file storage (images, attachments).
abstract interface class CloudStorage {
  Future<CloudResult<CloudUploadResult>> upload(CloudUploadConfig config);

  Future<CloudResult<String>> getDownloadUrl(String path);

  Future<CloudResult<CloudUnit>> deleteFile(String path);

  /// Emits 0.0–1.0 progress where the backend supports it.
  Stream<double> uploadProgress(CloudUploadConfig config);
}
