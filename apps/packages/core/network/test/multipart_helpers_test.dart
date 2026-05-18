import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('singleFileFormData', () {
    const bytes = [1, 2, 3, 4];
    const filename = 'doc.pdf';

    test('creates FormData with expected field and bytes', () {
      final form = singleFileFormData(
        fieldName: 'file',
        bytes: bytes,
        filename: filename,
      );
      expect(form.files, hasLength(1));
      final entry = form.files.single;
      expect(entry.key, 'file');
      expect(entry.value.filename, filename);
      expect(entry.value.length, bytes.length);
    });

    test('parses contentType when provided', () {
      final form = singleFileFormData(
        fieldName: 'file',
        bytes: bytes,
        filename: filename,
        contentType: 'application/pdf',
      );
      final file = form.files.single.value;
      expect(file.contentType?.type, 'application');
      expect(file.contentType?.subtype, 'pdf');
    });

    test('does not set pdf contentType when omitted', () {
      final form = singleFileFormData(
        fieldName: 'file',
        bytes: bytes,
        filename: 'upload.bin',
      );
      expect(form.files.single.value.contentType?.subtype, isNot('pdf'));
    });
  });
}
