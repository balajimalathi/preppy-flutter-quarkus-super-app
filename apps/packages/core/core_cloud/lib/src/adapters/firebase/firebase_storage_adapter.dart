import 'package:firebase_storage/firebase_storage.dart';

import '../../base/base_cloud_storage.dart';
import '../../models/cloud_download_url_request.dart';
import '../../models/cloud_result.dart';
import '../../models/cloud_upload.dart';

final class FirebaseStorageAdapter extends BaseCloudStorage {
  FirebaseStorageAdapter({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  CloudResult<R> mapStorageException<R>(Object error) {
    if (error is FirebaseException) {
      final code = switch (error.code) {
        'object-not-found' => CloudErrorCode.notFound,
        'unauthorized' => CloudErrorCode.permissionDenied,
        _ => CloudErrorCode.storageError,
      };
      return CloudError(message: error.message ?? error.code, code: code);
    }
    return super.mapStorageException(error);
  }

  @override
  Future<CloudResult<CloudUploadResult>> upload(
    CloudUploadConfig config,
  ) async {
    try {
      final ref = _storage.ref(config.path);
      await ref.putData(
        config.bytes,
        SettableMetadata(
          contentType: config.mimeType,
          customMetadata: config.metadata,
        ),
      );
      final url = await ref.getDownloadURL();
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
      // Firebase returns a tokenized URL. [CloudUrlKind.public] / [signed] /
      // [legacy] all use the same API; actual public access depends on rules.
      final url = await _storage.ref(path).getDownloadURL();
      return CloudSuccess(url);
    } catch (e) {
      return mapStorageException(e);
    }
  }

  @override
  Future<CloudResult<CloudUnit>> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
      return CloudSuccess(cloudUnit);
    } catch (e) {
      return mapStorageException(e);
    }
  }

  @override
  Stream<double> uploadProgress(CloudUploadConfig config) async* {
    try {
      final ref = _storage.ref(config.path);
      final task = ref.putData(
        config.bytes,
        SettableMetadata(
          contentType: config.mimeType,
          customMetadata: config.metadata,
        ),
      );
      yield 0;
      await for (final snap in task.snapshotEvents) {
        final total = snap.totalBytes;
        if (total > 0) {
          yield snap.bytesTransferred / total;
        }
      }
      yield 1;
    } catch (_) {
      yield 0;
    }
  }
}
