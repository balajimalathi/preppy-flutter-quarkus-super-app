import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';

/// Holds host-supplied callbacks for FCM + Awesome listener entry points.
///
/// Must be configured via [configure] before [CoreNotificationsFacade]
/// initializes remote notifications or attaches listeners.
class CoreNotificationsBridge {
  CoreNotificationsBridge._();

  /// Global singleton used by top-level notification entry points.
  static final CoreNotificationsBridge instance = CoreNotificationsBridge._();

  CoreNotificationsCallbacks _callbacks = const CoreNotificationsCallbacks();

  /// Installs host callbacks used by FCM/token/listener entry points.
  void configure(CoreNotificationsCallbacks callbacks) {
    _callbacks = callbacks;
  }

  /// Current callback set used by entry points.
  CoreNotificationsCallbacks get callbacks => _callbacks;

  /// Forwards the latest FCM registration token to the host callback.
  Future<void> onFcmToken(String token) =>
      _callbacks.onFcmToken?.call(token) ?? Future<void>.value();

  /// Forwards the native push token to the host callback.
  Future<void> onNativeToken(String token) =>
      _callbacks.onNativeToken?.call(token) ?? Future<void>.value();

  /// Forwards background FCM data messages to the host callback.
  Future<void> onFcmSilentData(FcmSilentData data) =>
      _callbacks.onFcmSilentData?.call(data) ?? Future<void>.value();

  static const String actionPortName = 'core_notifications_action_port';

  ReceivePort? _actionReceivePort;

  /// Registers a [ReceivePort] on the **main** isolate so background isolates can
  /// forward [ReceivedAction] when [CoreNotificationsCallbacks.enableActionPortBridge] is true.
  Future<void> installActionPortBridge(
    void Function(ReceivedAction action) onFromIsolate,
  ) async {
    await uninstallActionPortBridge();
    final port = ReceivePort('core_notifications_actions');
    _actionReceivePort = port;
    IsolateNameServer.removePortNameMapping(actionPortName);
    IsolateNameServer.registerPortWithName(port.sendPort, actionPortName);
    port.listen((message) {
      if (message is ReceivedAction) {
        onFromIsolate(message);
      }
    });
  }

  /// Removes the main-isolate action bridge if one is installed.
  Future<void> uninstallActionPortBridge() async {
    IsolateNameServer.removePortNameMapping(actionPortName);
    _actionReceivePort?.close();
    _actionReceivePort = null;
  }

  /// Dispatches an Awesome action either through the isolate bridge or directly.
  Future<void> onActionReceived(ReceivedAction action, String portName) async {
    if (action.actionType == ActionType.SilentAction ||
        action.actionType == ActionType.SilentBackgroundAction) {
      await (_callbacks.onSilentAction?.call(action) ?? Future<void>.value());
      return;
    }

    if (_callbacks.enableActionPortBridge) {
      final sendPort = IsolateNameServer.lookupPortByName(portName);
      if (sendPort != null) {
        sendPort.send(action);
        return;
      }
    }

    await (_callbacks.onActionReceived?.call(action) ?? Future<void>.value());
  }

  /// Forwards notification-created callbacks to the host.
  Future<void> onNotificationCreated(ReceivedNotification notification) =>
      _callbacks.onNotificationCreated?.call(notification) ??
      Future<void>.value();

  /// Forwards notification-displayed callbacks to the host.
  Future<void> onNotificationDisplayed(ReceivedNotification notification) =>
      _callbacks.onNotificationDisplayed?.call(notification) ??
      Future<void>.value();

  /// Dispatches notification dismiss actions through the isolate bridge when enabled.
  Future<void> onDismissActionReceived(
    ReceivedAction action,
    String portName,
  ) async {
    if (_callbacks.enableActionPortBridge) {
      final sendPort = IsolateNameServer.lookupPortByName(portName);
      if (sendPort != null) {
        sendPort.send(action);
        return;
      }
    }
    await (_callbacks.onDismissed?.call(action) ?? Future<void>.value());
  }
}

/// Host callbacks (all optional except typical usage adds at least token + action).
class CoreNotificationsCallbacks {
  const CoreNotificationsCallbacks({
    this.onFcmToken,
    this.onNativeToken,
    this.onFcmSilentData,
    this.onActionReceived,
    this.onSilentAction,
    this.onNotificationCreated,
    this.onNotificationDisplayed,
    this.onDismissed,
    this.enableActionPortBridge = false,
  });

  /// Called when Awesome FCM reports a new FCM registration token.
  final Future<void> Function(String token)? onFcmToken;

  /// Called when the native push provider exposes its underlying token.
  final Future<void> Function(String token)? onNativeToken;

  /// Called for silent/background FCM data messages.
  final Future<void> Function(FcmSilentData data)? onFcmSilentData;

  /// Called for regular notification actions on the current isolate.
  final Future<void> Function(ReceivedAction action)? onActionReceived;

  /// Called for silent action buttons/background actions.
  final Future<void> Function(ReceivedAction action)? onSilentAction;

  /// Called when Awesome reports that a notification was created.
  final Future<void> Function(ReceivedNotification notification)?
  onNotificationCreated;

  /// Called when Awesome reports that a notification was displayed.
  final Future<void> Function(ReceivedNotification notification)?
  onNotificationDisplayed;

  /// Called when the user dismisses a notification.
  final Future<void> Function(ReceivedAction action)? onDismissed;

  /// When true, [CoreNotificationsFacade.installActionPortBridgeForMainIsolate] must be
  /// called on the main isolate; non-main isolates forward [ReceivedAction] via [SendPort].
  final bool enableActionPortBridge;
}
