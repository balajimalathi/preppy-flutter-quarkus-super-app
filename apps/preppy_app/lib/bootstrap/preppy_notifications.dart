import 'dart:developer' as developer;

import 'package:core_notifications/core_notifications.dart';

import 'preppy_fcm_token_sync.dart';

/// Default FCM / local notification channels for Preppy.
const List<NotificationChannelDefinition> preppyNotificationChannels = [
  NotificationChannelDefinition(
    channelKey: 'general',
    channelName: 'General',
    channelDescription: 'General alerts and updates.',
    importance: NotificationImportance.High,
    defaultLayout: NotificationLayout.Default,
  ),
  NotificationChannelDefinition(
    channelKey: 'content',
    channelName: 'Content',
    channelDescription: 'Study content, uploads, and ingestion.',
    importance: NotificationImportance.Default,
    defaultLayout: NotificationLayout.Default,
  ),
];

/// Initializes Awesome Notifications + FCM after Firebase and Hive.
Future<void> initializePreppyNotifications({required bool debug}) async {
  CoreNotificationsBridge.instance.configure(
    CoreNotificationsCallbacks(
      onFcmToken: (token) async {
        PreppyFcmTokenSync.onTokenUpdated(token);
        if (token.isEmpty) {
          if (debug) {
            developer.log('FCM token cleared', name: 'PreppyFCM');
          }
          return;
        }
        if (debug) {
          developer.log(token, name: 'PreppyFCM.Token');
        }
      },
      onNativeToken: (token) async {
        assert(() {
          // ignore: avoid_print
          developer.log('core_notifications: native push token updated');
          return true;
        }());
      },
      // Payload logging is handled in @pragma entry points (main + background isolates).
    ),
  );

  await CoreNotificationsFacade.instance.initializeLocal(
    channels: preppyNotificationChannels,
    defaultIcon: 'resource://mipmap/ic_launcher',
    debug: debug,
  );
  await CoreNotificationsFacade.instance.initializeRemote(debug: debug);
  await CoreNotificationsFacade.instance.attachListeners();
  await CoreNotificationsFacade.instance.getInitialNotificationAction();

  if (debug) {
    final token = await CoreNotificationsFacade.instance
        .requestFirebaseAppToken();
    developer.log(token ?? '(null)', name: 'PreppyFCM.Token');
  }
}
