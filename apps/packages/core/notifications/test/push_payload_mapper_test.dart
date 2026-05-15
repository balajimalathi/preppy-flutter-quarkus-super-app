import 'package:core_notifications/core_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PushPayloadMapper builds content for channel_key', () {
    const def = NotificationChannelDefinition(
      channelKey: 'alerts',
      channelName: 'Alerts',
      channelDescription: 'Test',
    );
    final mapper = PushPayloadMapper({'alerts': def});
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

  test('PushPayloadMapper returns null without channel', () {
    const def = NotificationChannelDefinition(
      channelKey: 'alerts',
      channelName: 'Alerts',
      channelDescription: 'Test',
    );
    final mapper = PushPayloadMapper({'alerts': def});
    expect(mapper.toNotificationContent({'title': 'x'}), isNull);
  });
}
