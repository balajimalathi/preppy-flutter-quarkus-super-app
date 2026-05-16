import 'dart:developer' as developer;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'channel_definition.dart';
import 'notification_preferences_store.dart';
import 'push_payload_mapper.dart';

/// Shows a tray notification from FCM data inside the FCM background isolate.
///
/// FCM silent handlers run in a **separate FlutterEngine**; [IsolateNameServer]
/// on the main isolate is not visible there, so display must happen here.
class PushLocalDisplay {
  PushLocalDisplay._();

  static bool _backgroundReady = false;
  static List<NotificationChannelDefinition> _cachedChannels = [];

  static Future<bool> showFromFcmData(Map<String, String> data) async {
    if (data.isEmpty) {
      return false;
    }
    try {
      await _ensureBackgroundAwesomeReady();

      final mapper = PushPayloadMapper({
        for (final c in _cachedChannels) c.channelKey: c,
      });
      final content = mapper.toNotificationContent(data);
      if (content == null) {
        // ignore: avoid_print
        print('[PreppyPush.display] no mappable channel in payload');
        return false;
      }

      final shown = await AwesomeNotifications().createNotification(
        content: content,
      );
      // ignore: avoid_print
      print('[PreppyPush.display] createNotification=$shown');
      developer.log(
        'createNotification=$shown channel=${content.channelKey}',
        name: 'PreppyPush.display',
      );
      return shown;
    } catch (e, st) {
      // ignore: avoid_print
      print('[PreppyPush.display] failed: $e');
      developer.log(
        'showFromFcmData failed',
        name: 'PreppyPush.display',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  static Future<void> _ensureBackgroundAwesomeReady() async {
    if (_backgroundReady) {
      return;
    }

    await Hive.initFlutter();
    final prefs = NotificationPreferencesStore();
    await prefs.open();

    _cachedChannels = prefs.getSavedChannels();
    final defaultIcon =
        prefs.getSavedDefaultIcon() ?? 'resource://mipmap/ic_launcher';

    final channels =
        _cachedChannels.map((c) => c.toNotificationChannel()).toList(growable: false);

    await AwesomeNotifications().initialize(
      defaultIcon,
      channels,
      debug: false,
    );

    await prefs.close();
    _backgroundReady = true;
  }
}
