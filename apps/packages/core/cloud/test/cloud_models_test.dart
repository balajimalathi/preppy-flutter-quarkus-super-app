import 'dart:typed_data';

import 'package:core_cloud/core_cloud.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudBackend', () {
    test('lists all supported backends', () {
      expect(CloudBackend.values, [
        CloudBackend.firebase,
        CloudBackend.supabase,
        CloudBackend.neon,
        CloudBackend.s3,
      ]);
    });
  });

  group('CloudDocument', () {
    test('holds id, data, and optional timestamps', () {
      final created = DateTime.utc(2024, 1, 1);
      final updated = DateTime.utc(2024, 6, 1);
      const doc = CloudDocument<Map<String, dynamic>>(
        id: 'doc-1',
        data: {'name': 'Ada'},
        createdAt: null,
        updatedAt: null,
      );
      expect(doc.id, 'doc-1');
      expect(doc.data['name'], 'Ada');

      final withTimes = CloudDocument<String>(
        id: 'doc-2',
        data: 'hello',
        createdAt: created,
        updatedAt: updated,
      );
      expect(withTimes.createdAt, created);
      expect(withTimes.updatedAt, updated);
    });
  });

  group('CloudQuery', () {
    test('defaults filters and pagination fields', () {
      const q = CloudQuery();
      expect(q.filters, isEmpty);
      expect(q.orderBy, isNull);
      expect(q.descending, isFalse);
      expect(q.limit, isNull);
      expect(q.startAfter, isNull);
    });

    test('accepts filters and cursor', () {
      const q = CloudQuery(
        filters: [WhereEqual('status', 'active')],
        orderBy: 'createdAt',
        descending: true,
        limit: 10,
        startAfter: 'cursor-abc',
      );
      expect(q.filters, hasLength(1));
      expect(q.filters.first, isA<WhereEqual>());
      expect(q.orderBy, 'createdAt');
      expect(q.descending, isTrue);
      expect(q.limit, 10);
      expect(q.startAfter, 'cursor-abc');
    });
  });

  group('CloudFilter', () {
    test('WhereEqual stores field and value', () {
      const f = WhereEqual('userId', 42);
      expect(f.field, 'userId');
      expect(f.value, 42);
    });

    test('WhereIn stores field and values', () {
      const f = WhereIn('tag', ['a', 'b']);
      expect(f.field, 'tag');
      expect(f.values, ['a', 'b']);
    });

    test('WhereLessThan and WhereGreaterThan', () {
      const lt = WhereLessThan('score', 100);
      const gt = WhereGreaterThan('score', 0);
      expect(lt.value, 100);
      expect(gt.value, 0);
    });

    test('WhereContains requires string value', () {
      const f = WhereContains('title', 'exam');
      expect(f.field, 'title');
      expect(f.value, 'exam');
    });
  });

  group('CloudStreamEvent', () {
    test('added carries document', () {
      const doc = CloudDocument<int>(id: '1', data: 99);
      const event = CloudStreamAdded<int>(doc);
      expect(event.doc, doc);
    });

    test('modified carries document', () {
      const doc = CloudDocument<String>(id: '2', data: 'x');
      const event = CloudStreamModified<String>(doc);
      expect(event.doc.id, '2');
    });

    test('removed carries id only', () {
      const event = CloudStreamRemoved<void>('gone');
      expect(event.id, 'gone');
    });
  });

  group('CloudUploadConfig', () {
    test('stores path, bytes, mimeType, and metadata', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final cfg = CloudUploadConfig(
        path: 'uploads/a.png',
        bytes: bytes,
        mimeType: 'image/png',
        metadata: const {'author': 'test'},
      );
      expect(cfg.path, 'uploads/a.png');
      expect(cfg.bytes, bytes);
      expect(cfg.mimeType, 'image/png');
      expect(cfg.metadata, {'author': 'test'});
    });
  });

  group('CloudUploadResult', () {
    test('stores url, path, and size', () {
      const r = CloudUploadResult(
        url: 'https://cdn.example/f',
        path: 'f',
        sizeBytes: 1024,
      );
      expect(r.url, contains('cdn.example'));
      expect(r.path, 'f');
      expect(r.sizeBytes, 1024);
    });
  });

  group('CloudDownloadUrlRequest', () {
    test('defaults to legacy kind and one hour expiry', () {
      const req = CloudDownloadUrlRequest();
      expect(req.kind, CloudUrlKind.legacy);
      expect(req.expiresIn, const Duration(hours: 1));
    });

    test('accepts signed kind with custom expiry', () {
      const req = CloudDownloadUrlRequest(
        kind: CloudUrlKind.signed,
        expiresIn: Duration(minutes: 15),
      );
      expect(req.kind, CloudUrlKind.signed);
      expect(req.expiresIn, const Duration(minutes: 15));
    });

    test('CloudUrlKind includes public', () {
      expect(CloudUrlKind.values, contains(CloudUrlKind.public));
    });
  });
}
