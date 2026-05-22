import 'package:awesome_notifications/awesome_notifications.dart';

import '../core/core_notifications_bridge.dart';
import 'package:core_dev_debug/core_dev_debug.dart';

@pragma('vm:entry-point')
Future<void> coreNotificationsOnActionReceived(ReceivedAction action) async {
  await CoreNotificationsBridge.instance.onActionReceived(
    action,
    CoreNotificationsBridge.actionPortName,
  );
  PushReceiveDebugLog.instance.ingestAction(PushReceiveKind.action, action);
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnNotificationCreated(
  ReceivedNotification notification,
) async {
  await CoreNotificationsBridge.instance.onNotificationCreated(notification);
  PushReceiveDebugLog.instance.ingestNotification(
    PushReceiveKind.created,
    notification,
  );
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnNotificationDisplayed(
  ReceivedNotification notification,
) async {
  await CoreNotificationsBridge.instance.onNotificationDisplayed(notification);
  PushReceiveDebugLog.instance.ingestNotification(
    PushReceiveKind.displayed,
    notification,
  );
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnDismissActionReceived(
  ReceivedAction action,
) async {
  await CoreNotificationsBridge.instance.onDismissActionReceived(
    action,
    CoreNotificationsBridge.actionPortName,
  );
  PushReceiveDebugLog.instance.ingestAction(PushReceiveKind.dismissed, action);
}
