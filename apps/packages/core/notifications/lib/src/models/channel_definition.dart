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

  /// Stable identifier used by Awesome Notifications and payload mapping.
  final String channelKey;

  /// User-visible channel name shown in system settings.
  final String channelName;

  /// User-visible explanation of what this channel is used for.
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

  /// Converts this definition into the plugin's runtime channel model.
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

  /// Serializes this definition for Hive persistence.
  Map<String, dynamic> toMap() {
    return {
      'channelKey': channelKey,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'importance': importance.name,
      'channelShowBadge': channelShowBadge,
      'playSound': playSound,
      'enableVibration': enableVibration,
      'enableLights': enableLights,
      'ledColor': ledColor?.value,
      'groupKey': groupKey,
      'channelGroupKey': channelGroupKey,
      'defaultColor': defaultColor?.value,
      'defaultPrivacy': defaultPrivacy?.name,
      'defaultLayout': defaultLayout.name,
      'icon': icon,
      'soundSource': soundSource,
      'defaultRingtoneType': defaultRingtoneType?.name,
    };
  }

  /// Rehydrates a saved definition from [toMap].
  factory NotificationChannelDefinition.fromMap(Map<String, dynamic> map) {
    return NotificationChannelDefinition(
      channelKey: map['channelKey'] as String,
      channelName: map['channelName'] as String,
      channelDescription: map['channelDescription'] as String,
      importance: NotificationImportance.values.firstWhere(
        (e) => e.name == map['importance'],
        orElse: () => NotificationImportance.Default,
      ),
      channelShowBadge: map['channelShowBadge'] as bool? ?? true,
      playSound: map['playSound'] as bool? ?? true,
      enableVibration: map['enableVibration'] as bool? ?? true,
      enableLights: map['enableLights'] as bool? ?? false,
      ledColor: map['ledColor'] != null ? Color(map['ledColor'] as int) : null,
      groupKey: map['groupKey'] as String?,
      channelGroupKey: map['channelGroupKey'] as String?,
      defaultColor: map['defaultColor'] != null
          ? Color(map['defaultColor'] as int)
          : null,
      defaultPrivacy: map['defaultPrivacy'] != null
          ? NotificationPrivacy.values.firstWhere(
              (e) => e.name == map['defaultPrivacy'],
              orElse: () => NotificationPrivacy.Private,
            )
          : null,
      defaultLayout: NotificationLayout.values.firstWhere(
        (e) => e.name == map['defaultLayout'],
        orElse: () => NotificationLayout.Default,
      ),
      icon: map['icon'] as String?,
      soundSource: map['soundSource'] as String?,
      defaultRingtoneType: map['defaultRingtoneType'] != null
          ? DefaultRingtoneType.values.firstWhere(
              (e) => e.name == map['defaultRingtoneType'],
              orElse: () => DefaultRingtoneType.Notification,
            )
          : null,
    );
  }
}
