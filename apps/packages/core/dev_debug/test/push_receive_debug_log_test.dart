import 'package:core_dev_debug/core_dev_debug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushReceiveDebugLog', () {
    final log = PushReceiveDebugLog.instance;

    setUp(() {
      log.events.value = const [];
    });

    test('record prepends events and caps at 50', () {
      for (var i = 0; i < 55; i++) {
        log.record(
          PushReceiveEvent(
            kind: PushReceiveKind.created,
            summary: 'event-$i',
            raw: const {},
          ),
        );
      }
      expect(log.events.value, hasLength(50));
      expect(log.events.value.first.summary, 'event-54');
    });

    test('ingest records directly when relay port is unavailable', () {
      log.ingest(
        PushReceiveEvent(
          kind: PushReceiveKind.silentData,
          summary: 'silent payload',
          raw: {'title': 'Test'},
          source: 'test',
        ),
      );
      expect(log.events.value, hasLength(1));
      expect(log.events.value.first.summary, 'silent payload');
    });
  });
}
