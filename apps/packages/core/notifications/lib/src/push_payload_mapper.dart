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
  ///
  /// Supports flat README keys (`channel_key`, `title`, …) and Awesome FCM
  /// flattened keys (`content.channelKey`, `content.title`, …).
  NotificationContent? toNotificationContent(Map<String, String> data) {
    final normalized = normalizeFcmData(data);

    final channelKey =
        normalized['channel_key'] ??
        normalized['channelKey'] ??
        normalized['android_channel_id'];
    if (channelKey == null || channelKey.isEmpty) {
      return null;
    }
    final channel = _channelsByKey[channelKey];
    final id =
        int.tryParse(normalized['id'] ?? '') ?? channelKey.hashCode.abs();

    final layout =
        _parseLayout(
          normalized['layout'] ?? normalized['notification_layout'],
        ) ??
        channel?.defaultLayout ??
        NotificationLayout.Default;

    final lines = _parseLines(normalized['lines'] ?? normalized['inbox_lines']);
    final body =
        normalized['body'] ??
        (lines != null && lines.isNotEmpty ? lines.join('\n') : null);

    final rawPayload = normalized['payload'];
    Map<String, String?>? payloadMap;
    if (rawPayload != null && rawPayload.isNotEmpty) {
      payloadMap = {'raw': rawPayload};
    }

    return NotificationContent(
      id: id,
      channelKey: channelKey,
      title: normalized['title'],
      body: body,
      summary: normalized['summary'],
      largeIcon: normalized['large_icon'] ?? normalized['largeIcon'],
      bigPicture: normalized['big_picture'] ?? normalized['bigPicture'],
      icon: normalized['icon'],
      customSound: normalized['custom_sound'] ?? normalized['customSound'],
      payload: payloadMap,
      category: _parseCategory(normalized['category']),
      groupKey: normalized['group_key'] ?? normalized['groupKey'],
      badge: int.tryParse(normalized['badge'] ?? ''),
      ticker: normalized['ticker'],
      notificationLayout: layout,
      displayOnForeground:
          (normalized['display_on_foreground'] ??
              normalized['displayOnForeground']) !=
          'false',
      displayOnBackground:
          (normalized['display_on_background'] ??
              normalized['displayOnBackground']) !=
          'false',
      locked: normalized['locked'] == 'true',
      hideLargeIconOnExpand: normalized['hide_large_icon_on_expand'] == 'true',
      progress: double.tryParse(normalized['progress'] ?? ''),
      color: _parseColor(normalized['color']),
      backgroundColor: _parseColor(
        normalized['background_color'] ?? normalized['backgroundColor'],
      ),
      wakeUpScreen: normalized['wake_up_screen'] == 'true',
      fullScreenIntent: normalized['full_screen_intent'] == 'true',
    );
  }

  /// Merges Awesome Notifications FCM flattened keys into flat mapper keys.
  static Map<String, String> normalizeFcmData(Map<String, String> data) {
    final out = Map<String, String>.from(data);

    final jsonContent = data['content'];
    if (jsonContent != null && jsonContent.startsWith('{')) {
      try {
        final decoded = jsonDecode(jsonContent);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            out.putIfAbsent(entry.key.toString(), () => entry.value.toString());
          }
        }
      } catch (_) {}
    }

    for (final entry in data.entries) {
      const prefix = 'content.';
      if (entry.key.startsWith(prefix)) {
        out.putIfAbsent(entry.key.substring(prefix.length), () => entry.value);
      }
    }

    return out;
  }

  /// Whether [channelKey] is registered in [PushPayloadMapper].
  bool isKnownChannel(String channelKey) =>
      _channelsByKey.containsKey(channelKey);

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
