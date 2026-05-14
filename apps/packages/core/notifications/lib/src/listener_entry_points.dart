import 'package:awesome_notifications/awesome_notifications.dart';

import 'core_notifications_bridge.dart';

@pragma('vm:entry-point')
Future<void> coreNotificationsOnActionReceived(ReceivedAction action) async {
  await CoreNotificationsBridge.instance.onActionReceived(
    action,
    CoreNotificationsBridge.actionPortName,
  );
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnNotificationCreated(
  ReceivedNotification notification,
) async {
  await CoreNotificationsBridge.instance.onNotificationCreated(notification);
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnNotificationDisplayed(
  ReceivedNotification notification,
) async {
  await CoreNotificationsBridge.instance.onNotificationDisplayed(notification);
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnDismissActionReceived(
  ReceivedAction action,
) async {
  await CoreNotificationsBridge.instance.onDismissActionReceived(
    action,
    CoreNotificationsBridge.actionPortName,
  );
}
