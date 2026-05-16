import 'dart:developer' as developer;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/channel_definition.dart';
import '../storage/notification_preferences_store.dart';
import 'push_payload_mapper.dart';

/// Shows a tray notification from FCM data inside the FCM background isolate.
///
/// FCM silent handlers run in a **separate FlutterEngine**; [IsolateNameServer]
/// on the main isolate is not visible there, so display must happen here.
class PushLocalDisplay {
  PushLocalDisplay._();

  static bool _backgroundReady = false;
  static List<NotificationChannelDefinition> _cachedChannels = [];

  /// Channels from the last [CoreNotificationsFacade.initializeLocal] call.
  ///
  /// Used when Hive has no persisted config in the FCM background isolate.
  static List<NotificationChannelDefinition> hostFallbackChannels = const [];

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
        developer.log('No mappable channel in payload', name: 'PreppyPush.display');
        return false;
      }

      final channelKey = content.channelKey;
      if (channelKey != null) {
        final prefs = NotificationPreferencesStore();
        await prefs.open();
        final enabled = prefs.isChannelEnabled(channelKey);
        await prefs.close();
        if (!enabled) {
          developer.log(
            'Channel disabled in prefs: $channelKey',
            name: 'PreppyPush.display',
          );
          return false;
        }
      }

      final shown = await AwesomeNotifications().createNotification(
        content: content,
      );
      // ignore: avoid_print
      developer.log('createNotification=$shown', name: 'PreppyPush.display');
      developer.log(
        'createNotification=$shown channel=${content.channelKey}',
        name: 'PreppyPush.display',
      );
      return shown;
    } catch (e, st) {
      // ignore: avoid_print
      developer.log('failed: $e', name: 'PreppyPush.display');
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
    if (_cachedChannels.isEmpty && hostFallbackChannels.isNotEmpty) {
      _cachedChannels = List<NotificationChannelDefinition>.from(
        hostFallbackChannels,
      );
      developer.log(
        'using host fallback channels (${_cachedChannels.length})',
        name: 'PreppyPush.display',
      );
    }
    final defaultIcon =
        prefs.getSavedDefaultIcon() ?? 'resource://mipmap/ic_launcher';

    final channels = _cachedChannels
        .map((c) => c.toNotificationChannel())
        .toList(growable: false);

    await AwesomeNotifications().initialize(
      defaultIcon,
      channels,
      debug: false,
    );

    await prefs.close();
    _backgroundReady = true;
  }
}
