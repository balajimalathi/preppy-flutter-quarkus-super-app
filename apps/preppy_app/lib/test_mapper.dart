import 'package:flutter/material.dart';
import 'package:core_notifications/core_notifications.dart';

void main() {
  final mapper = PushPayloadMapper({
    'general': const NotificationChannelDefinition(
      channelKey: 'general',
      channelName: 'General',
      channelDescription: 'General alerts and updates.',
      importance: NotificationImportance.High,
      defaultLayout: NotificationLayout.Default,
    ),
  });

  final data = {
    "content.id": "1",
    "content.channelKey": "general",
    "content.title": "Preppy test",
    "content.body": "Awesome Notifications payload",
    "content.displayOnForeground": "true",
    "content.displayOnBackground": "true"
  };

  final content = mapper.toNotificationContent(data);
  if (content != null) {
    print("Content successfully parsed: id=${content.id}, title=${content.title}, body=${content.body}");
    print("Content Map: ${content.toMap()}");
  } else {
    print("Failed to parse content.");
  }
}
