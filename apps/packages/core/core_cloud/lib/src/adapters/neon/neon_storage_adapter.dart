import '../../base/base_cloud_storage.dart';
import '../../models/cloud_result.dart';
import '../../models/cloud_upload.dart';

/// Placeholder storage for Neon-backed apps (wire S3/R2 via a dedicated adapter).
final class NeonStorageAdapter extends BaseCloudStorage {
  @override
  Future<CloudResult<CloudUploadResult>> upload(
    CloudUploadConfig config,
  ) async {
    return CloudError<CloudUploadResult>(
      message:
          'NeonStorageAdapter.upload is not implemented — use S3/R2 or Supabase Storage.',
      code: CloudErrorCode.unsupported,
    );
  }

  @override
  Future<CloudResult<String>> getDownloadUrl(String path) async {
    return CloudError<String>(
      message: 'NeonStorageAdapter.getDownloadUrl is not implemented.',
      code: CloudErrorCode.unsupported,
    );
  }

  @override
  Future<CloudResult<CloudUnit>> deleteFile(String path) async {
    return CloudError<CloudUnit>(
      message: 'NeonStorageAdapter.deleteFile is not implemented.',
      code: CloudErrorCode.unsupported,
    );
  }

  @override
  Stream<double> uploadProgress(CloudUploadConfig config) async* {
    yield 0;
  }
}
