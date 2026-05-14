import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'channel_definition.dart';

/// Maps FCM `data` payloads into [NotificationContent] for local display
/// (e.g. foreground) using keys documented in the package README.
class PushPayloadMapper {
  PushPayloadMapper(this._channelsByKey);

  final Map<String, NotificationChannelDefinition> _channelsByKey;

  /// Parses [data] values as strings (typical FCM data map).
  NotificationContent? toNotificationContent(Map<String, String> data) {
    final channelKey =
        data['channel_key'] ?? data['channelKey'] ?? data['android_channel_id'];
    if (channelKey == null || channelKey.isEmpty) {
      return null;
    }
    final channel = _channelsByKey[channelKey];
    final id = int.tryParse(data['id'] ?? '') ?? channelKey.hashCode.abs();

    final layout =
        _parseLayout(data['layout'] ?? data['notification_layout']) ??
        channel?.defaultLayout ??
        NotificationLayout.Default;

    final lines = _parseLines(data['lines'] ?? data['inbox_lines']);
    final body =
        data['body'] ??
        (lines != null && lines.isNotEmpty ? lines.join('\n') : null);

    final rawPayload = data['payload'];
    Map<String, String?>? payloadMap;
    if (rawPayload != null && rawPayload.isNotEmpty) {
      payloadMap = {'raw': rawPayload};
    }

    return NotificationContent(
      id: id,
      channelKey: channelKey,
      title: data['title'],
      body: body,
      summary: data['summary'],
      largeIcon: data['large_icon'] ?? data['largeIcon'],
      bigPicture: data['big_picture'] ?? data['bigPicture'],
      icon: data['icon'],
      customSound: data['custom_sound'] ?? data['customSound'],
      payload: payloadMap,
      category: _parseCategory(data['category']),
      groupKey: data['group_key'] ?? data['groupKey'],
      badge: int.tryParse(data['badge'] ?? ''),
      ticker: data['ticker'],
      notificationLayout: layout,
      displayOnForeground:
          (data['display_on_foreground'] ?? data['displayOnForeground']) !=
          'false',
      displayOnBackground:
          (data['display_on_background'] ?? data['displayOnBackground']) !=
          'false',
      locked: data['locked'] == 'true',
      hideLargeIconOnExpand: data['hide_large_icon_on_expand'] == 'true',
      progress: double.tryParse(data['progress'] ?? ''),
      color: _parseColor(data['color']),
      backgroundColor: _parseColor(
        data['background_color'] ?? data['backgroundColor'],
      ),
      wakeUpScreen: data['wake_up_screen'] == 'true',
      fullScreenIntent: data['full_screen_intent'] == 'true',
    );
  }

  /// JSON map suitable for [AwesomeNotifications.createNotificationFromJsonData].
  Map<String, dynamic>? toJsonData(Map<String, String> data) {
    final content = toNotificationContent(data);
    return content?.toMap();
  }

  NotificationLayout? _parseLayout(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final normalized = raw.replaceAll('-', '_').toLowerCase();
    for (final v in NotificationLayout.values) {
      if (v.name.toLowerCase() == normalized) {
        return v;
      }
    }
    return null;
  }

  List<String>? _parseLines(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return raw
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Color? _parseColor(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    var hex = raw.trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final value = int.tryParse(hex, radix: 16);
    if (value == null) {
      return null;
    }
    return Color(value);
  }

  NotificationCategory? _parseCategory(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final normalized = raw.replaceAll('-', '_').toLowerCase();
    for (final v in NotificationCategory.values) {
      if (v.name.toLowerCase() == normalized) {
        return v;
      }
    }
    return null;
  }
}
