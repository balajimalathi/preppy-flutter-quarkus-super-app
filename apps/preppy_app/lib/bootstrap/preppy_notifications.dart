import 'package:core_notifications/core_notifications.dart';

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
        assert(() {
          // ignore: avoid_print
          print(
            'core_notifications: FCM token updated (${token.isEmpty ? 'cleared' : 'set'})',
          );
          return true;
        }());
      },
      onNativeToken: (token) async {
        assert(() {
          // ignore: avoid_print
          print('core_notifications: native push token updated');
          return true;
        }());
      },
      onFcmSilentData: (data) async {
        assert(() {
          // ignore: avoid_print
          print('core_notifications: silent data ${data.data}');
          return true;
        }());
      },
      onActionReceived: (action) async {
        assert(() {
          // ignore: avoid_print
          print(
            'core_notifications: action ${action.id} ${action.buttonKeyPressed}',
          );
          return true;
        }());
      },
    ),
  );

  await CoreNotificationsFacade.instance.initializeLocal(
    channels: preppyNotificationChannels,
    defaultIcon: null,
    debug: debug,
  );
  await CoreNotificationsFacade.instance.initializeRemote(debug: debug);
  await CoreNotificationsFacade.instance.attachListeners();
  await CoreNotificationsFacade.instance.requestPermission();
  await CoreNotificationsFacade.instance.getInitialNotificationAction();
}
