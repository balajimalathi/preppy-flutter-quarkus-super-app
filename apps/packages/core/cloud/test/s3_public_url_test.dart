import 'package:core_cloud/src/adapters/s3/s3_public_url.dart';
import 'package:core_cloud/src/adapters/s3/s3_storage_config.dart';
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
  });
}
