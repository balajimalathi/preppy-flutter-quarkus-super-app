import 'package:core_notifications/core_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushReceiveEvent', () {
    test('toJson and fromJson round-trip', () {
      final original = PushReceiveEvent(
        kind: PushReceiveKind.silentData,
        summary: 'title=Hi, body=There',
        raw: {'channel_key': 'alerts', 'title': 'Hi'},
        source: 'FcmSilentData',
        at: DateTime.utc(2026, 5, 16, 12),
      );

      final restored = PushReceiveEvent.fromJson(original.toJson());
      expect(restored.kind, original.kind);
      expect(restored.summary, original.summary);
      expect(restored.source, original.source);
      expect(restored.at, original.at);
      expect(restored.raw, original.raw);
    });

    test('kindLabel maps enum to display string', () {
      expect(
        PushReceiveEvent(
          kind: PushReceiveKind.created,
          summary: '',
          raw: {},
        ).kindLabel,
        'created',
      );
      expect(
        PushReceiveEvent(
          kind: PushReceiveKind.dismissed,
          summary: '',
          raw: {},
        ).kindLabel,
        'dismissed',
      );
    });

    test('dataForMapper stringifies raw values', () {
      final event = PushReceiveEvent(
        kind: PushReceiveKind.displayed,
        summary: 'test',
        raw: {'channel_key': 'alerts', 'count': 3, 'flag': true},
      );
      expect(event.dataForMapper, {
        'channel_key': 'alerts',
        'count': '3',
        'flag': 'true',
      });
    });

    test('prettyJson includes kind and summary', () {
      final event = PushReceiveEvent(
        kind: PushReceiveKind.action,
        summary: 'tap',
        raw: const {},
        source: 'ReceivedAction',
      );
      expect(event.prettyJson, contains('"kind": "action"'));
      expect(event.prettyJson, contains('"summary": "tap"'));
    });
  });
}
