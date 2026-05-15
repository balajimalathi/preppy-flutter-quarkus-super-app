import 'dart:convert';

import 'package:hive_ce/hive.dart';

import 'push_receive_debug_log.dart';

/// Persists recent push payloads in Hive for inspection across app restarts.
class PushPayloadHistoryStore {
  PushPayloadHistoryStore({this.boxName = 'core_notifications_push_log'});

  final String boxName;
  static const _eventsKey = 'events';
  static const int maxStoredEvents = 50;

  Box<String>? _box;

  Future<void> open() async {
    _box ??= await Hive.openBox<String>(boxName);
  }

  Future<List<PushReceiveEvent>> loadAll() async {
    final box = _box;
    if (box == null) {
      return const [];
    }
    final raw = box.get(_eventsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => PushReceiveEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> replaceAll(List<PushReceiveEvent> events) async {
    final box = _box;
    if (box == null) {
      return;
    }
    final trimmed = events.length > maxStoredEvents
        ? events.sublist(0, maxStoredEvents)
        : events;
    await box.put(
      _eventsKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<void> clear() async {
    await _box?.delete(_eventsKey);
  }

  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
