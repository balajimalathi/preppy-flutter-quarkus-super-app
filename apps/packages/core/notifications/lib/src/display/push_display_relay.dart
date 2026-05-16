import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

/// Forwards FCM data to the main isolate when both handlers share a Dart VM.
///
/// FCM silent pushes usually run in a separate FlutterEngine where this relay
/// is unavailable; use [PushLocalDisplay] for that path.
class PushDisplayRelay {
  PushDisplayRelay._();

  static final PushDisplayRelay instance = PushDisplayRelay._();

  static const String _portName = 'preppy_push_display_port';

  ReceivePort? _receivePort;
  Future<bool> Function(Map<String, String> data)? _onDisplay;

  void install(Future<bool> Function(Map<String, String> data) onDisplay) {
    _onDisplay = onDisplay;
    _receivePort?.close();
    final port = ReceivePort('preppy_push_display');
    _receivePort = port;
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);
    port.listen((message) async {
      if (_onDisplay == null) {
        return;
      }
      try {
        if (message is List && message.length == 2 && message[1] is SendPort) {
          final data = _mapFromMessage(message[0]);
          final reply = message[1] as SendPort;
          final shown = data.isEmpty ? false : await _onDisplay!(data);
          reply.send(shown);
          return;
        }
      } catch (e, st) {
        developer.log(
          'display failed',
          name: 'PreppyPush.display',
          error: e,
          stackTrace: st,
        );
      }
    });
  }

  Future<bool> requestDisplayAndWait(Map<String, String> data) async {
    if (data.isEmpty) {
      return false;
    }
    final relay = IsolateNameServer.lookupPortByName(_portName);
    if (relay == null) {
      return false;
    }
    final response = ReceivePort();
    relay.send(<Object>[Map<String, String>.from(data), response.sendPort]);
    final result = await response.first;
    response.close();
    return result == true;
  }

  Map<String, String> _mapFromMessage(Object? message) {
    if (message is! Map) {
      return const {};
    }
    return Map<String, String>.from(
      message.map((key, value) => MapEntry(key.toString(), value.toString())),
    );
  }
}
