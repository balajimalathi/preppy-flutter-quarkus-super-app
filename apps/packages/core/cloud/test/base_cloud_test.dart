import 'package:core_cloud/core_cloud.dart';
import 'package:core_cloud/src/adapters/s3/s3_storage_adapter.dart';
import 'package:core_cloud/src/base/base_cloud_collection.dart';
import 'package:core_cloud/src/base/base_cloud_storage.dart';
import 'package:flutter_test/flutter_test.dart';

final class _TestStorage extends BaseCloudStorage {
  @override
  Future<CloudResult<CloudUnit>> deleteFile(String path) =>
      throw UnimplementedError();

  @override
  Future<CloudResult<String>> getDownloadUrl(
    String path, {
    CloudDownloadUrlRequest request = const CloudDownloadUrlRequest(),
  }) => throw UnimplementedError();

  @override
  Future<CloudResult<CloudUploadResult>> upload(CloudUploadConfig config) =>
      throw UnimplementedError();

  @override
  Stream<double> uploadProgress(CloudUploadConfig config) =>
      throw UnimplementedError();
}

final class _TestCollection extends BaseCloudCollection<Map<String, dynamic>> {
  _TestCollection()
    : super(
        collectionName: 'items',
        fromJson: (json) => json,
        toJson: (value) => value,
      );
}

void main() {
  group('BaseCloudStorage', () {
    late _TestStorage storage;

    setUp(() => storage = _TestStorage());

    test('mapStorageException wraps generic errors', () {
      final result = storage.mapStorageException<String>(
        Exception('disk full'),
      );
      expect(result, isA<CloudError<String>>());
      final err = result as CloudError<String>;
      expect(err.code, CloudErrorCode.storageError);
      expect(err.message, contains('disk full'));
    });
  });

  group('BaseCloudCollection', () {
    late _TestCollection collection;

    setUp(() => collection = _TestCollection());

    test('exposes collection name and serializers', () {
      expect(collection.collectionName, 'items');
      expect(collection.fromJson({'a': 1}), {'a': 1});
      expect(collection.toJson({'b': 2}), {'b': 2});
    });

    test('mapException returns CloudError with message', () {
      final result = collection.mapException<int>(
        StateError('bad state'),
        code: CloudErrorCode.transactionFailed,
      );
      expect(result, isA<CloudError<int>>());
      final err = result as CloudError<int>;
      expect(err.code, CloudErrorCode.transactionFailed);
      expect(err.message, contains('bad state'));
    });

    test('mapException defaults to unknown code', () {
      final result = collection.mapException<void>(ArgumentError('nope'));
      expect((result as CloudError<void>).code, CloudErrorCode.unknown);
    });

    test('retryStream passes through unchanged', () async {
      final events = [
        const CloudSuccess<int>(1),
        const CloudError<int>(message: 'x', code: CloudErrorCode.networkError),
      ];
      final out = await collection
          .retryStream(Stream.fromIterable(events))
          .toList();
      expect(out, events);
    });
  });

  group('S3CompatibleStorageAdapter.mapStorageException', () {
    late S3CompatibleStorageAdapter adapter;

    setUp(() {
      adapter = S3CompatibleStorageAdapter(
        config: const S3StorageConfig(
          endpoint: 'localhost',
          accessKey: 'k',
          secretKey: 's',
          region: 'us-east-1',
          bucket: 'b',
        ),
      );
    });

    test('maps 404 to notFound', () {
      final result = adapter.mapStorageException<void>(
        S3HttpException(404, ''),
      );
      expect((result as CloudError<void>).code, CloudErrorCode.notFound);
      expect(result.message, '404');
    });

    test('maps 403 to permissionDenied', () {
      final result = adapter.mapStorageException<void>(
        S3HttpException(403, 'Forbidden'),
      );
      expect(
        (result as CloudError<void>).code,
        CloudErrorCode.permissionDenied,
      );
      expect(result.message, 'Forbidden');
    });

    test('maps other status codes to storageError', () {
      final result = adapter.mapStorageException<void>(
        S3HttpException(500, 'Internal'),
      );
      expect((result as CloudError<void>).code, CloudErrorCode.storageError);
    });

    test('delegates non-S3 errors to base storage mapping', () {
      final result = adapter.mapStorageException<void>(Exception('network'));
      expect((result as CloudError<void>).code, CloudErrorCode.storageError);
    });
  });

  group('S3HttpException', () {
    test('toString includes status and body', () {
      final ex = S3HttpException(418, "I'm a teapot");
      expect(ex.toString(), "S3HttpException(418): I'm a teapot");
    });
  });
}
