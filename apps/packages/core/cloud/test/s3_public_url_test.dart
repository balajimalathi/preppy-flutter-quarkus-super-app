import 'package:core_cloud/src/adapters/s3/s3_public_url.dart';
import 'package:core_cloud/src/adapters/s3/s3_storage_config.dart';
import 'package:core_cloud/src/models/cloud_download_url_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('S3PublicUrl', () {
    test('joinBaseAndKey trims slashes', () {
      expect(
        S3PublicUrl.joinBaseAndKey('https://cdn.example/', '/a/b'),
        'https://cdn.example/a/b',
      );
      expect(
        S3PublicUrl.joinBaseAndKey('https://cdn.example', 'a/b'),
        'https://cdn.example/a/b',
      );
    });

    test('encodeObjectPath encodes segments', () {
      expect(S3PublicUrl.encodeObjectPath('a/b c'), 'a/b%20c');
    });

    test('encodeObjectPath skips empty segments', () {
      expect(S3PublicUrl.encodeObjectPath('/a//b/'), 'a/b');
    });

    test('joinBaseAndKey handles empty object key', () {
      expect(
        S3PublicUrl.joinBaseAndKey('https://cdn.example', ''),
        'https://cdn.example/',
      );
    });

    test('build uses publicBaseUrl when set', () {
      const cfg = S3StorageConfig(
        endpoint: 'ignored',
        accessKey: 'k',
        secretKey: 's',
        region: 'us-east-1',
        bucket: 'b',
        publicBaseUrl: 'https://cdn.example/root',
      );
      expect(
        S3PublicUrl.build(config: cfg, objectKey: 'x/y'),
        'https://cdn.example/root/x/y',
      );
    });

    test('build path-style without publicBaseUrl', () {
      const cfg = S3StorageConfig(
        endpoint: 'localhost',
        accessKey: 'k',
        secretKey: 's',
        region: 'us-east-1',
        bucket: 'mybucket',
        useSSL: false,
        port: 9000,
        enablePathStyle: true,
      );
      expect(
        S3PublicUrl.build(config: cfg, objectKey: 'f/photo 1.jpg'),
        'http://localhost:9000/mybucket/f/photo%201.jpg',
      );
    });

    test('build virtual-hosted omits default ports', () {
      const cfg = S3StorageConfig(
        endpoint: 's3.amazonaws.com',
        accessKey: 'k',
        secretKey: 's',
        region: 'us-east-1',
        bucket: 'mybucket',
        useSSL: true,
        port: 443,
        enablePathStyle: false,
      );
      expect(
        S3PublicUrl.build(config: cfg, objectKey: 'k'),
        'https://mybucket.s3.amazonaws.com/k',
      );
    });

    test('build path-style omits default http port 80', () {
      const cfg = S3StorageConfig(
        endpoint: 'minio.local',
        accessKey: 'k',
        secretKey: 's',
        region: 'us-east-1',
        bucket: 'files',
        useSSL: false,
        port: 80,
        enablePathStyle: true,
      );
      expect(
        S3PublicUrl.build(config: cfg, objectKey: 'doc.pdf'),
        'http://minio.local/files/doc.pdf',
      );
    });

    test('build virtual-hosted includes non-default port', () {
      const cfg = S3StorageConfig(
        endpoint: 'localhost',
        accessKey: 'k',
        secretKey: 's',
        region: 'us-east-1',
        bucket: 'b',
        useSSL: true,
        port: 9443,
        enablePathStyle: false,
      );
      expect(
        S3PublicUrl.build(config: cfg, objectKey: 'x'),
        'https://b.localhost:9443/x',
      );
    });
  });

  group('S3StorageConfig', () {
    test('defaults use SSL, path-style off, and signed upload URLs', () {
      const cfg = S3StorageConfig(
        endpoint: 's3.example.com',
        accessKey: 'k',
        secretKey: 's',
        region: 'auto',
        bucket: 'my-bucket',
      );
      expect(cfg.useSSL, isTrue);
      expect(cfg.enablePathStyle, isFalse);
      expect(cfg.publicBaseUrl, isNull);
      expect(cfg.defaultSignedExpiry, const Duration(hours: 1));
      expect(cfg.uploadResultUrlKind, CloudUrlKind.signed);
    });
  });
}
