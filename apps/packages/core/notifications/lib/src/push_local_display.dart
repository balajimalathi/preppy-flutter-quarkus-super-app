import 'dart:developer' as developer;

import 'package:awesome_notifications/awesome_notifications.dart';

import 'channel_definition.dart';
import 'push_payload_mapper.dart';

/// Channels used when showing FCM payloads from the background Dart isolate.
/// Must match channels registered in the host app ([initializeLocal]).
const List<NotificationChannelDefinition> kDefaultFcmDisplayChannels = [
  NotificationChannelDefinition(
    channelKey: 'general',
    channelName: 'General',
    channelDescription: 'General alerts and updates.',
    importance: NotificationImportance.High,
  ),
  NotificationChannelDefinition(
    channelKey: 'content',
    channelName: 'Content',
    channelDescription: 'Study content, uploads, and ingestion.',
  ),
];

/// Shows a tray notification from FCM data inside the FCM background isolate.
///
/// FCM silent handlers run in a **separate FlutterEngine**; [IsolateNameServer]
/// on the main isolate is not visible there, so display must happen here.
class PushLocalDisplay {
  PushLocalDisplay._();

  static bool _backgroundReady = false;

  static Future<bool> showFromFcmData(Map<String, String> data) async {
    if (data.isEmpty) {
      return false;
    }
    try {
      await _ensureBackgroundAwesomeReady();

      final mapper = PushPayloadMapper({
        for (final c in kDefaultFcmDisplayChannels) c.channelKey: c,
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
    final channels = kDefaultFcmDisplayChannels
        .map((c) => c.toNotificationChannel())
        .toList(growable: false);
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      channels,
      debug: false,
    );
    _backgroundReady = true;
  }
}
