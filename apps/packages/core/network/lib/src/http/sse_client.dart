import 'dart:convert';

import 'package:dio/dio.dart';

/// One logical SSE event (after merging `data:` continuation lines).
final class SseMessage {
  const SseMessage({this.id, this.event, required this.data});

  final String? id;
  final String? event;

  /// Joined payload lines (excluding trailing `\n` from the spec).
  final String data;
}

/// Parses `text/event-stream` from a GET [path] on the shared [Dio] base URL.
///
/// Do not enable global retry interceptors on streaming requests.
final class SseClient {
  SseClient(this._dio);

  final Dio _dio;

  /// Emits [SseMessage] for each completed `data:` block (per SSE framing).
  Stream<SseMessage> subscribe(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async* {
    final response = await _dio.get<ResponseBody>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream', ...?headers},
      ),
    );

    final body = response.data;
    if (body == null) {
      return;
    }

    final buffer = StringBuffer();
    String? id;
    String? event;
    final dataLines = <String>[];

    SseMessage? takeEventIfReady() {
      if (dataLines.isEmpty) {
        return null;
      }
      final data = dataLines.join('\n');
      dataLines.clear();
      final msg = SseMessage(id: id, event: event, data: data);
      id = null;
      event = null;
      return msg;
    }

    await for (final chunk in body.stream) {
      buffer.write(utf8.decode(chunk, allowMalformed: true));
      var raw = buffer.toString();
      buffer.clear();

      final endsWithNewline = raw.endsWith('\n');
      if (!endsWithNewline) {
        final lastBreak = raw.lastIndexOf('\n');
        if (lastBreak == -1) {
          buffer.write(raw);
          continue;
        }
        buffer.write(raw.substring(lastBreak + 1));
        raw = raw.substring(0, lastBreak + 1);
      }

      var start = 0;
      while (start <= raw.length) {
        final nl = raw.indexOf('\n', start);
        final end = nl == -1 ? raw.length : nl;
        final line = raw.substring(start, end).replaceAll('\r', '');
        start = nl == -1 ? raw.length + 1 : nl + 1;

        if (line.isEmpty) {
          final msg = takeEventIfReady();
          if (msg != null) {
            yield msg;
          }
          continue;
        }
        if (line.startsWith(':')) {
          continue;
        }
        final colon = line.indexOf(':');
        final field = colon == -1 ? line : line.substring(0, colon).trim();
        var value = colon == -1 ? '' : line.substring(colon + 1);
        if (value.startsWith(' ')) {
          value = value.substring(1);
        }
        switch (field) {
          case 'id':
            id = value;
          case 'event':
            event = value;
          case 'data':
            dataLines.add(value);
          default:
            break;
        }
      }
    }
    final msg = takeEventIfReady();
    if (msg != null) {
      yield msg;
    }
  }
}
