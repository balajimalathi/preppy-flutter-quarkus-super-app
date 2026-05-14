import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

/// Builds [FormData] for a single file field (e.g. PDF binary upload).
FormData singleFileFormData({
  required String fieldName,
  required List<int> bytes,
  required String filename,
  String? contentType,
}) {
  return FormData.fromMap({
    fieldName: MultipartFile.fromBytes(
      bytes,
      filename: filename,
      contentType: contentType != null ? MediaType.parse(contentType) : null,
    ),
  });
}
