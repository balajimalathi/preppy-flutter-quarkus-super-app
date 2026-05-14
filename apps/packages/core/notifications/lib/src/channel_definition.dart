import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

/// Declarative Android channel + defaults for notifications using [channelKey].
class NotificationChannelDefinition {
  const NotificationChannelDefinition({
    required this.channelKey,
    required this.channelName,
    required this.channelDescription,
    this.importance = NotificationImportance.Default,
    this.channelShowBadge = true,
    this.playSound = true,
    this.enableVibration = true,
    this.enableLights = false,
    this.ledColor,
    this.groupKey,
    this.channelGroupKey,
    this.defaultColor,
    this.defaultPrivacy,
    this.defaultLayout = NotificationLayout.Default,
    this.icon,
    this.soundSource,
    this.defaultRingtoneType,
  });

  final String channelKey;
  final String channelName;
  final String channelDescription;
  final NotificationImportance importance;
  final bool channelShowBadge;
  final bool playSound;
  final bool enableVibration;
  final bool enableLights;
  final Color? ledColor;
  final String? groupKey;
  final String? channelGroupKey;
  final Color? defaultColor;
  final NotificationPrivacy? defaultPrivacy;

  /// Suggested layout when mapping FCM payloads without an explicit layout.
  final NotificationLayout defaultLayout;

  final String? icon;
  final String? soundSource;
  final DefaultRingtoneType? defaultRingtoneType;

  NotificationChannel toNotificationChannel() {
    return NotificationChannel(
      channelKey: channelKey,
      channelName: channelName,
      channelDescription: channelDescription,
      importance: importance,
      channelShowBadge: channelShowBadge,
      playSound: playSound,
      enableVibration: enableVibration,
      enableLights: enableLights,
      ledColor: ledColor,
      groupKey: groupKey,
      channelGroupKey: channelGroupKey,
      defaultColor: defaultColor,
      defaultPrivacy: defaultPrivacy,
      icon: icon,
      soundSource: soundSource,
      defaultRingtoneType: defaultRingtoneType,
    );
  }
}
