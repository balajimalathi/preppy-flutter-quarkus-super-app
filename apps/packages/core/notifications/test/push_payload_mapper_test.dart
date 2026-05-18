import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const alertsDef = NotificationChannelDefinition(
    channelKey: 'alerts',
    channelName: 'Alerts',
    channelDescription: 'Test',
  );

  group('PushPayloadMapper.normalizeFcmData', () {
    test('merges JSON content blob into flat keys', () {
      final normalized = PushPayloadMapper.normalizeFcmData({
        'content': '{"channelKey":"alerts","title":"From JSON"}',
      });
      expect(normalized['channelKey'], 'alerts');
      expect(normalized['title'], 'From JSON');
    });

    test('merges content. prefixed Awesome keys', () {
      final normalized = PushPayloadMapper.normalizeFcmData({
        'content.channelKey': 'general',
        'content.body': 'Body',
        'title': 'Flat wins if duplicate key absent',
      });
      expect(normalized['channelKey'], 'general');
      expect(normalized['body'], 'Body');
    });
  });

  group('PushPayloadMapper.toNotificationContent', () {
    test('builds content for channel_key', () {
      final mapper = PushPayloadMapper({'alerts': alertsDef});
      final content = mapper.toNotificationContent({
        'channel_key': 'alerts',
        'title': 'Hello',
        'body': 'World',
        'layout': 'BigPicture',
      });
      expect(content, isNotNull);
      expect(content!.channelKey, 'alerts');
      expect(content.title, 'Hello');
      expect(content.body, 'World');
      expect(content.notificationLayout, NotificationLayout.BigPicture);
    });

    test('PushPayloadMapper builds content for Awesome flattened keys', () {
      const def = NotificationChannelDefinition(
        channelKey: 'general',
        channelName: 'General',
        channelDescription: 'Test',
      );
      final mapper = PushPayloadMapper({'general': def});
      final content = mapper.toNotificationContent({
        'content.channelKey': 'general',
        'content.title': 'Preppy test',
        'content.body': 'Hello',
        'content.displayOnForeground': 'true',
        'createdSource': 'Firebase',
      });
      expect(content, isNotNull);
      expect(content!.channelKey, 'general');
      expect(content.title, 'Preppy test');
      expect(content.body, 'Hello');
    });

    test('returns null without channel', () {
      final mapper = PushPayloadMapper({'alerts': alertsDef});
      expect(mapper.toNotificationContent({'title': 'x'}), isNull);
    });

    test('uses android_channel_id as channel key', () {
      final mapper = PushPayloadMapper({'alerts': alertsDef});
      final content = mapper.toNotificationContent({
        'android_channel_id': 'alerts',
        'title': 'T',
      });
      expect(content?.channelKey, 'alerts');
    });

    test('uses channel default layout when payload omits layout', () {
      const def = NotificationChannelDefinition(
        channelKey: 'alerts',
        channelName: 'Alerts',
        channelDescription: 'Test',
        defaultLayout: NotificationLayout.Inbox,
      );
      final mapper = PushPayloadMapper({'alerts': def});
      final content = mapper.toNotificationContent({
        'channel_key': 'alerts',
        'lines': '["One","Two"]',
      });
      expect(content?.notificationLayout, NotificationLayout.Inbox);
      expect(content?.body, 'One\nTwo');
    });

    test('parses inbox lines from pipe-separated string', () {
      final mapper = PushPayloadMapper({'alerts': alertsDef});
      final content = mapper.toNotificationContent({
        'channel_key': 'alerts',
        'lines': 'A|B|C',
      });
      expect(content?.body, 'A\nB\nC');
    });

    test('parses color and category fields', () {
      final mapper = PushPayloadMapper({'alerts': alertsDef});
      final content = mapper.toNotificationContent({
        'channel_key': 'alerts',
        'color': '#FF0000',
        'category': 'Message',
      });
      expect(content?.color, const Color(0xFFFF0000));
      expect(content?.category, NotificationCategory.Message);
    });

    test('honors display_on_foreground false', () {
      final mapper = PushPayloadMapper({'alerts': alertsDef});
      final content = mapper.toNotificationContent({
        'channel_key': 'alerts',
        'display_on_foreground': 'false',
      });
      expect(content?.displayOnForeground, isFalse);
    });

    test('isKnownChannel reflects registered channels', () {
      final mapper = PushPayloadMapper({'alerts': alertsDef});
      expect(mapper.isKnownChannel('alerts'), isTrue);
      expect(mapper.isKnownChannel('missing'), isFalse);
    });
  });
}
