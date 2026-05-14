import '../contracts/cloud_storage.dart';
import '../models/cloud_result.dart';

abstract base class BaseCloudStorage implements CloudStorage {
  CloudResult<R> mapStorageException<R>(Object error) {
    return CloudError<R>(
      message: error.toString(),
      code: CloudErrorCode.storageError,
    );
  }
}
