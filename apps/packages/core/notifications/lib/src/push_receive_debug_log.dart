import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:flutter/foundation.dart';

import 'push_payload_history_store.dart';

/// In-memory + Hive log of push / local notification events and raw payloads.
///
/// FCM silent handlers run in a background Dart isolate where host [configure]
/// callbacks are empty. Entry points call [ingest] so payloads are always
/// captured and forwarded to the main isolate for the UI.
class PushReceiveDebugLog {
  PushReceiveDebugLog._();

  static final PushReceiveDebugLog instance = PushReceiveDebugLog._();

  static const int _maxEvents = 50;
  static const String _relayPortName = 'preppy_push_receive_log_port';

  final PushPayloadHistoryStore historyStore = PushPayloadHistoryStore();
  final ValueNotifier<List<PushReceiveEvent>> events = ValueNotifier(const []);

  ReceivePort? _relayReceivePort;
  bool _hydrated = false;

  /// Call after [Hive.initFlutter] (e.g. from [CoreNotificationsFacade.initializeLocal]).
  Future<void> open() async {
    _installMainIsolateRelay();
    await historyStore.open();
    if (_hydrated) {
      return;
    }
    _hydrated = true;
    final stored = await historyStore.loadAll();
    if (stored.isNotEmpty) {
      events.value = stored;
    }
  }

  void _installMainIsolateRelay() {
    _relayReceivePort?.close();
    final port = ReceivePort('preppy_push_log_relay');
    _relayReceivePort = port;
    IsolateNameServer.removePortNameMapping(_relayPortName);
    IsolateNameServer.registerPortWithName(port.sendPort, _relayPortName);
    port.listen((message) {
      if (message is Map) {
        record(PushReceiveEvent.fromJson(Map<String, dynamic>.from(message)));
      }
    });
  }

  /// Records on the main isolate when possible; always logs to console.
  ///
  /// Never throws — logging must not break Awesome FCM handlers.
  void ingest(PushReceiveEvent event) {
    try {
      developer.log(event.summary, name: 'PreppyPush.${event.kind}');
      developer.log(event.prettyJson, name: 'PreppyPush.raw');
      // ignore: avoid_print
      print('[PreppyPush.${event.kindLabel}] ${event.summary}');

      final relay = IsolateNameServer.lookupPortByName(_relayPortName);
      if (relay != null) {
        // SendPort only accepts transferable values (Map), not custom objects.
        relay.send(event.toJson());
        return;
      }

      record(event);
    } catch (e, st) {
      developer.log(
        'PushReceiveDebugLog.ingest failed',
        name: 'PreppyPush',
        error: e,
        stackTrace: st,
      );
    }
  }

  void record(PushReceiveEvent event) {
    try {
      final next = [event, ...events.value];
      if (next.length > _maxEvents) {
        events.value = next.sublist(0, _maxEvents);
      } else {
        events.value = next;
      }

      historyStore.replaceAll(events.value);
    } catch (e, st) {
      developer.log(
        'PushReceiveDebugLog.record failed',
        name: 'PreppyPush',
        error: e,
        stackTrace: st,
      );
    }
  }

  void ingestSilentData(FcmSilentData data) {
    ingest(
      PushReceiveEvent(
        kind: PushReceiveKind.silentData,
        summary: _formatMap(data.data),
        raw: _sanitizeMap(data.toMap()),
        source: 'FcmSilentData',
      ),
    );
  }

  void ingestNotification(
    PushReceiveKind kind,
    ReceivedNotification notification,
  ) {
    final raw = _sanitizeMap(notification.toMap());
    final parts = <String>[
      if (notification.title?.isNotEmpty == true) notification.title!,
      if (notification.body?.isNotEmpty == true) notification.body!,
      if (notification.channelKey?.isNotEmpty == true)
        'channel=${notification.channelKey}',
      'id=${notification.id}',
    ];
    ingest(
      PushReceiveEvent(
        kind: kind,
        summary: parts.isEmpty ? '(empty notification)' : parts.join(' · '),
        raw: raw,
        source: 'ReceivedNotification',
      ),
    );
  }

  void ingestAction(PushReceiveKind kind, ReceivedAction action) {
    ingest(
      PushReceiveEvent(
        kind: kind,
        summary:
            'id=${action.id} channel=${action.channelKey} '
            'button=${action.buttonKeyPressed}',
        raw: _sanitizeMap(action.toMap()),
        source: 'ReceivedAction',
      ),
    );
  }

  Future<void> clear() async {
    events.value = const [];
    await historyStore.clear();
  }

  String _formatMap(Map<String, String?>? data) {
    if (data == null || data.isEmpty) {
      return '(empty data)';
    }
    return data.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value == null) {
        return MapEntry(key, null);
      }
      if (value is Map) {
        return MapEntry(key, _sanitizeMap(Map<String, dynamic>.from(value)));
      }
      if (value is List) {
        return MapEntry(
          key,
          value.map((e) => e?.toString()).toList(growable: false),
        );
      }
      return MapEntry(key, value.toString());
    });
  }
}

enum PushReceiveKind { created, displayed, silentData, action, dismissed }

class PushReceiveEvent {
  PushReceiveEvent({
    required this.kind,
    required this.summary,
    required this.raw,
    this.source,
    DateTime? at,
  }) : at = at ?? DateTime.now();

  factory PushReceiveEvent.fromJson(Map<String, dynamic> json) {
    return PushReceiveEvent(
      kind: PushReceiveKind.values.byName(json['kind'] as String),
      summary: json['summary'] as String? ?? '',
      raw: Map<String, dynamic>.from(json['raw'] as Map? ?? {}),
      source: json['source'] as String?,
      at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final DateTime at;
  final PushReceiveKind kind;
  final String summary;
  final Map<String, dynamic> raw;
  final String? source;

  String get kindLabel => switch (kind) {
    PushReceiveKind.created => 'created',
    PushReceiveKind.displayed => 'displayed',
    PushReceiveKind.silentData => 'silent',
    PushReceiveKind.action => 'action',
    PushReceiveKind.dismissed => 'dismissed',
  };

  /// String map suitable for [PushPayloadMapper.toNotificationContent].
  Map<String, String> get dataForMapper {
    final result = <String, String>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value != null) {
        result[entry.key] = value.toString();
      }
    }
    return result;
  }

  String get prettyJson {
    return const JsonEncoder.withIndent('  ').convert({
      'at': at.toIso8601String(),
      'kind': kind.name,
      'source': source,
      'summary': summary,
      'raw': raw,
    });
  }

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'kind': kind.name,
    'source': source,
    'summary': summary,
    'raw': raw,
  };
}
