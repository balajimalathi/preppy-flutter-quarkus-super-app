import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';

import 'core_notifications_bridge.dart';

@pragma('vm:entry-point')
Future<void> coreNotificationsOnFcmToken(String token) async {
  await CoreNotificationsBridge.instance.onFcmToken(token);
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnFcmSilentData(FcmSilentData data) async {
  await CoreNotificationsBridge.instance.onFcmSilentData(data);
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnNativeToken(String token) async {
  await CoreNotificationsBridge.instance.onNativeToken(token);
}
