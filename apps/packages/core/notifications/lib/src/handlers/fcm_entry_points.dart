import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';

import '../core/core_notifications_bridge.dart';
import '../debug/push_receive_debug_log.dart';
import '../display/push_display_relay.dart';
import '../display/push_local_display.dart';

Map<String, String> _fcmDataStrings(FcmSilentData data) {
  final raw = data.data;
  if (raw == null || raw.isEmpty) {
    return const {};
  }
  return Map<String, String>.fromEntries(
    raw.entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!)),
  );
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnFcmToken(String token) async {
  await CoreNotificationsBridge.instance.onFcmToken(token);
}


@pragma('vm:entry-point')
Future<void> coreNotificationsOnFcmSilentData(FcmSilentData data) async {
  await CoreNotificationsBridge.instance.onFcmSilentData(data);

  final payload = _fcmDataStrings(data);
  if (payload.isNotEmpty) {
    final relayed = await PushDisplayRelay.instance.requestDisplayAndWait(payload);
    if (!relayed) {
      await PushLocalDisplay.showFromFcmData(payload);
    }
  }

  PushReceiveDebugLog.instance.ingestSilentData(data);
}

@pragma('vm:entry-point')
Future<void> coreNotificationsOnNativeToken(String token) async {
  await CoreNotificationsBridge.instance.onNativeToken(token);
}
