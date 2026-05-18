import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

ReceivedAction _action({
  required int id,
  required String channelKey,
  ActionType actionType = ActionType.Default,
  String buttonKeyPressed = '',
}) {
  return ReceivedAction()..fromMap({
    'id': id,
    'channelKey': channelKey,
    'actionType': actionType.name,
    'buttonKeyPressed': buttonKeyPressed,
  });
}

ReceivedNotification _notification({
  required int id,
  required String channelKey,
  String title = '',
}) {
  return ReceivedNotification()
    ..fromMap({'id': id, 'channelKey': channelKey, 'title': title});
}

FcmSilentData _silentData(Map<String, String> entries) {
  return FcmSilentData()
    ..fromMap({'id': 1, for (final e in entries.entries) e.key: e.value});
}

void main() {
  group('CoreNotificationsBridge', () {
    late CoreNotificationsBridge bridge;

    setUp(() {
      bridge = CoreNotificationsBridge.instance;
      bridge.configure(const CoreNotificationsCallbacks());
    });

    test('onFcmToken invokes configured callback', () async {
      String? received;
      bridge.configure(
        CoreNotificationsCallbacks(
          onFcmToken: (token) async {
            received = token;
          },
        ),
      );
      await bridge.onFcmToken('abc');
      expect(received, 'abc');
    });

    test('onFcmSilentData invokes configured callback', () async {
      var called = false;
      bridge.configure(
        CoreNotificationsCallbacks(
          onFcmSilentData: (data) async {
            called = true;
            expect(data.data?['key'], 'value');
          },
        ),
      );
      await bridge.onFcmSilentData(_silentData({'key': 'value'}));
      expect(called, isTrue);
    });

    test('onActionReceived routes silent actions to onSilentAction', () async {
      var silentHandled = false;
      bridge.configure(
        CoreNotificationsCallbacks(
          onSilentAction: (action) async {
            silentHandled = true;
            expect(action.id, 42);
          },
        ),
      );

      await bridge.onActionReceived(
        _action(
          id: 42,
          channelKey: 'alerts',
          actionType: ActionType.SilentAction,
        ),
        CoreNotificationsBridge.actionPortName,
      );
      expect(silentHandled, isTrue);
    });

    test(
      'onActionReceived invokes onActionReceived for default actions',
      () async {
        var received = false;
        bridge.configure(
          CoreNotificationsCallbacks(
            onActionReceived: (action) async {
              received = true;
              expect(action.buttonKeyPressed, 'btn_ok');
            },
          ),
        );

        await bridge.onActionReceived(
          _action(id: 1, channelKey: 'alerts', buttonKeyPressed: 'btn_ok'),
          CoreNotificationsBridge.actionPortName,
        );
        expect(received, isTrue);
      },
    );

    test('onNotificationCreated invokes configured callback', () async {
      var received = false;
      bridge.configure(
        CoreNotificationsCallbacks(
          onNotificationCreated: (_) async {
            received = true;
          },
        ),
      );
      await bridge.onNotificationCreated(
        _notification(id: 9, channelKey: 'alerts', title: 'Hi'),
      );
      expect(received, isTrue);
    });

    test(
      'onDismissActionReceived invokes onDismissed when port bridge off',
      () async {
        var dismissed = false;
        bridge.configure(
          CoreNotificationsCallbacks(
            onDismissed: (_) async {
              dismissed = true;
            },
          ),
        );
        await bridge.onDismissActionReceived(
          _action(id: 2, channelKey: 'alerts'),
          CoreNotificationsBridge.actionPortName,
        );
        expect(dismissed, isTrue);
      },
    );

    test('callbacks default to no-op when not configured', () async {
      await bridge.onFcmToken('x');
      await bridge.onNativeToken('y');
      await bridge.onNotificationDisplayed(
        _notification(id: 1, channelKey: 'c'),
      );
    });
  });
}
