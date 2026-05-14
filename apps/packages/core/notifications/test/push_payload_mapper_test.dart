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
