import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationChannelDefinition', () {
    const def = NotificationChannelDefinition(
      channelKey: 'alerts',
      channelName: 'Alerts',
      channelDescription: 'Important alerts',
      importance: NotificationImportance.High,
      channelShowBadge: false,
      playSound: false,
      enableVibration: false,
      enableLights: true,
      ledColor: Color(0xFFFF0000),
      groupKey: 'grp',
      channelGroupKey: 'grp_main',
      defaultColor: Color(0xFF00FF00),
      defaultPrivacy: NotificationPrivacy.Public,
      defaultLayout: NotificationLayout.BigText,
      icon: 'resource://drawable/ic_alert',
      soundSource: 'resource://raw/alert',
      defaultRingtoneType: DefaultRingtoneType.Alarm,
    );

    test('toNotificationChannel copies channel metadata', () {
      final channel = def.toNotificationChannel();
      expect(channel.channelKey, 'alerts');
      expect(channel.channelName, 'Alerts');
      expect(channel.importance, NotificationImportance.High);
      expect(channel.defaultColor, const Color(0xFF00FF00));
    });

    test('toMap and fromMap round-trip', () {
      final map = def.toMap();
      final restored = NotificationChannelDefinition.fromMap(map);
      expect(restored.channelKey, def.channelKey);
      expect(restored.channelName, def.channelName);
      expect(restored.importance, def.importance);
      expect(restored.channelShowBadge, def.channelShowBadge);
      expect(restored.ledColor, def.ledColor);
      expect(restored.defaultLayout, def.defaultLayout);
      expect(restored.defaultRingtoneType, def.defaultRingtoneType);
    });

    test('fromMap uses defaults for missing optional fields', () {
      final minimal = NotificationChannelDefinition.fromMap({
        'channelKey': 'general',
        'channelName': 'General',
        'channelDescription': 'Default channel',
      });
      expect(minimal.importance, NotificationImportance.Default);
      expect(minimal.channelShowBadge, isTrue);
      expect(minimal.defaultLayout, NotificationLayout.Default);
      expect(minimal.ledColor, isNull);
    });
  });
}
