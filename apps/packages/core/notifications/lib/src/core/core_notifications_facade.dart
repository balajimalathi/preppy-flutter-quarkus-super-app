import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';

import '../debug/push_receive_debug_log.dart';
import '../display/push_display_relay.dart';
import '../display/push_payload_mapper.dart';
import '../handlers/fcm_entry_points.dart';
import '../handlers/listener_entry_points.dart';
import '../models/channel_definition.dart';
import '../storage/notification_preferences_store.dart';
import 'core_notifications_bridge.dart';

/// Host-agnostic Awesome Notifications + FCM setup.
///
/// Call only after [Firebase.initializeApp] and [Hive.initFlutter] in the host app.
class CoreNotificationsFacade {
  CoreNotificationsFacade._();
  static final CoreNotificationsFacade instance = CoreNotificationsFacade._();

  final NotificationPreferencesStore preferences =
      NotificationPreferencesStore();

  PushPayloadMapper? _mapper;

  bool _localReady = false;
  bool _remoteReady = false;
  bool _listenersReady = false;

  /// Maps FCM data payloads to [NotificationContent] using the last channel set from [initializeLocal].
  PushPayloadMapper get payloadMapper {
    final mapper = _mapper;
    if (mapper == null) {
      throw StateError(
        'initializeLocal() must be called before using payloadMapper',
      );
    }
    return mapper;
  }

  /// Opens Hive preferences, initializes Awesome Notifications, and registers Android channels.
  Future<bool> initializeLocal({
    required List<NotificationChannelDefinition> channels,
    String? defaultIcon,
    bool debug = false,
    List<NotificationChannelGroup>? channelGroups,
  }) async {
    await preferences.open();
    await preferences.saveInitializationConfig(channels, defaultIcon);
    await PushReceiveDebugLog.instance.open();
    final notificationChannels =
        channels.map((c) => c.toNotificationChannel()).toList(growable: false);
    _mapper = PushPayloadMapper({for (final c in channels) c.channelKey: c});

    final ok = await AwesomeNotifications().initialize(
      defaultIcon,
      notificationChannels,
      channelGroups: channelGroups,
      debug: debug,
    );
    _localReady = ok;
    if (ok) {
      PushDisplayRelay.instance.install(showLocalFromDataIfEnabled);
    }
    return ok;
  }

  /// Initializes Awesome Notifications FCM (requires Firebase already initialized).
  Future<bool> initializeRemote({bool debug = false}) async {
    if (!_localReady) {
      throw StateError(
        'initializeLocal() must be called before initializeRemote()',
      );
    }
    final ok = await AwesomeNotificationsFcm().initialize(
      onFcmTokenHandle: coreNotificationsOnFcmToken,
      onFcmSilentDataHandle: coreNotificationsOnFcmSilentData,
      onNativeTokenHandle: coreNotificationsOnNativeToken,
      debug: debug,
    );
    _remoteReady = ok;
    return ok;
  }

  /// Wires Awesome listener entry points. Requires [CoreNotificationsBridge.configure].
  Future<bool> attachListeners() async {
    if (!_localReady) {
      throw StateError(
        'initializeLocal() must be called before attachListeners()',
      );
    }
    final ok = await AwesomeNotifications().setListeners(
      onActionReceivedMethod: coreNotificationsOnActionReceived,
      onNotificationCreatedMethod: coreNotificationsOnNotificationCreated,
      onNotificationDisplayedMethod: coreNotificationsOnNotificationDisplayed,
      onDismissActionReceivedMethod: coreNotificationsOnDismissActionReceived,
    );
    _listenersReady = ok;
    return ok;
  }

  /// Optional: register main-isolate bridge for background action delivery.
  Future<void> installActionPortBridgeForMainIsolate(
    void Function(ReceivedAction action) onAction,
  ) {
    return CoreNotificationsBridge.instance.installActionPortBridge(onAction);
  }

  Future<void> uninstallActionPortBridge() {
    return CoreNotificationsBridge.instance.uninstallActionPortBridge();
  }

  /// Runtime notification permission (Android 13+ / iOS).
  Future<bool> requestPermission({
    String? channelKey,
    List<NotificationPermission> permissions = const [
      NotificationPermission.Alert,
      NotificationPermission.Sound,
      NotificationPermission.Badge,
      NotificationPermission.Vibration,
      NotificationPermission.Light,
    ],
  }) {
    return AwesomeNotifications().requestPermissionToSendNotifications(
      channelKey: channelKey,
      permissions: permissions,
    );
  }

  Future<String?> requestFirebaseAppToken() async {
    final token = await AwesomeNotificationsFcm().requestFirebaseAppToken();
    if (token.isEmpty) {
      return null;
    }
    return token;
  }

  Future<bool> subscribeToTopic(String topic) =>
      AwesomeNotificationsFcm().subscribeToTopic(topic);

  Future<bool> unsubscribeFromTopic(String topic) =>
      AwesomeNotificationsFcm().unsubscribeToTopic(topic);

  Future<bool> deleteFcmToken() => AwesomeNotificationsFcm().deleteToken();

  Future<bool> isFirebaseAvailableForFcm() =>
      AwesomeNotificationsFcm().isFirebaseAvailable;

  /// Shows a notification from FCM-style string data if the channel is enabled in Hive prefs.
  Future<bool> showLocalFromDataIfEnabled(Map<String, String> data) async {
    if (!_localReady) {
      return false;
    }
    final content = payloadMapper.toNotificationContent(data);
    if (content == null) {
      return false;
    }
    final key = content.channelKey;
    if (key == null || !preferences.isChannelEnabled(key)) {
      return false;
    }
    return AwesomeNotifications().createNotification(content: content);
  }

  Future<ReceivedAction?> getInitialNotificationAction({
    bool removeFromActionEvents = false,
  }) {
    return AwesomeNotifications().getInitialNotificationAction(
      removeFromActionEvents: removeFromActionEvents,
    );
  }

  bool get isLocalInitialized => _localReady;
  bool get isRemoteInitialized => _remoteReady;
  bool get areListenersAttached => _listenersReady;
}
