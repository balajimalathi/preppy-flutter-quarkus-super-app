import 'package:hive_ce/hive.dart';

/// Per-channel opt-in stored in Hive (after [Hive.initFlutter] in the host app).
class NotificationPreferencesStore {
  NotificationPreferencesStore({this.boxName = 'core_notifications_prefs'});

  final String boxName;
  Box<bool>? _box;

  static const _keyPrefix = 'channel_enabled:';

  Future<void> open() async {
    _box = await Hive.openBox<bool>(boxName);
  }

  bool isChannelEnabled(String channelKey) {
    final box = _box;
    if (box == null) {
      return true;
    }
    return box.get('$_keyPrefix$channelKey', defaultValue: true) ?? true;
  }

  Future<void> setChannelEnabled(String channelKey, bool enabled) async {
    final box = _box;
    if (box == null) {
      throw StateError('NotificationPreferencesStore.open() was not called');
    }
    await box.put('$_keyPrefix$channelKey', enabled);
  }

  Future<void> clearChannel(String channelKey) async {
    final box = _box;
    if (box == null) {
      return;
    }
    await box.delete('$_keyPrefix$channelKey');
  }

  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
