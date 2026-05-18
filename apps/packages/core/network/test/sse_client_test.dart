import 'dart:convert';
import 'dart:typed_data';

import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Dio _dioWithSseStream(Stream<Uint8List> chunks) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<ResponseBody>(
            requestOptions: options,
            data: ResponseBody(
              chunks,
              200,
              headers: {
                Headers.contentTypeHeader: ['text/event-stream'],
              },
            ),
          ),
        );
      },
    ),
  );
  return dio;
}

Future<List<SseMessage>> _collect(SseClient client, String path) {
  return client.subscribe(path).toList();
}

void main() {
  group('SseClient', () {
    test('parses a single data event', () async {
      final messages = await _collect(
        SseClient(
          _dioWithSseStream(
            Stream.value(Uint8List.fromList(utf8.encode('data: hello\n\n'))),
          ),
        ),
        '/events',
      );
      expect(messages, hasLength(1));
      expect(messages.single.data, 'hello');
    });

    test('parses id and event fields', () async {
      final payload = 'id: 1\nevent: ping\ndata: x\n\n';
      final messages = await _collect(
        SseClient(
          _dioWithSseStream(
            Stream.value(Uint8List.fromList(utf8.encode(payload))),
          ),
        ),
        '/events',
      );
      expect(messages.single.id, '1');
      expect(messages.single.event, 'ping');
      expect(messages.single.data, 'x');
    });

    test('joins multiple data lines', () async {
      final payload = 'data: line1\ndata: line2\n\n';
      final messages = await _collect(
        SseClient(
          _dioWithSseStream(
            Stream.value(Uint8List.fromList(utf8.encode(payload))),
          ),
        ),
        '/events',
      );
      expect(messages.single.data, 'line1\nline2');
    });

    test('ignores comment lines', () async {
      final payload = ': keepalive\ndata: ok\n\n';
      final messages = await _collect(
        SseClient(
          _dioWithSseStream(
            Stream.value(Uint8List.fromList(utf8.encode(payload))),
          ),
        ),
        '/events',
      );
      expect(messages.single.data, 'ok');
    });

    test('handles chunk split mid-line', () async {
      final chunks = Stream.fromIterable([
        Uint8List.fromList(utf8.encode('data: hel')),
        Uint8List.fromList(utf8.encode('lo\n\n')),
      ]);
      final messages = await _collect(
        SseClient(_dioWithSseStream(chunks)),
        '/events',
      );
      expect(messages.single.data, 'hello');
    });

    test('yields nothing when response body is null', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<ResponseBody>(requestOptions: options, data: null),
            );
          },
        ),
      );
      final messages = await _collect(SseClient(dio), '/events');
      expect(messages, isEmpty);
    });

    test('emits trailing event without final blank line', () async {
      final messages = await _collect(
        SseClient(
          _dioWithSseStream(
            Stream.value(Uint8List.fromList(utf8.encode('data: tail\n'))),
          ),
        ),
        '/events',
      );
      expect(messages, hasLength(1));
      expect(messages.single.data, 'tail');
    });
  });
}
