import 'package:hive_ce/hive.dart';

import 'channel_definition.dart';

/// Per-channel opt-in and initialization config stored in Hive.
class NotificationPreferencesStore {
  NotificationPreferencesStore({this.boxName = 'core_notifications_prefs'});

  final String boxName;
  Box<bool>? _box;
  Box<dynamic>? _configBox;

  static const _keyPrefix = 'channel_enabled:';
  static const configBoxName = 'core_notifications_config';

  Future<void> open() async {
    _box = await Hive.openBox<bool>(boxName);
    _configBox = await Hive.openBox<dynamic>(configBoxName);
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

  Future<void> saveInitializationConfig(
    List<NotificationChannelDefinition> channels,
    String? defaultIcon,
  ) async {
    final box = _configBox;
    if (box == null) return;
    await box.put('channels', channels.map((c) => c.toMap()).toList());
    if (defaultIcon != null) {
      await box.put('defaultIcon', defaultIcon);
    } else {
      await box.delete('defaultIcon');
    }
  }

  List<NotificationChannelDefinition> getSavedChannels() {
    final box = _configBox;
    if (box == null) return [];
    final raw = box.get('channels');
    if (raw is List) {
      return raw
          .map((e) {
            if (e is Map) {
              return NotificationChannelDefinition.fromMap(
                Map<String, dynamic>.from(e),
              );
            }
            return null;
          })
          .whereType<NotificationChannelDefinition>()
          .toList();
    }
    return [];
  }

  String? getSavedDefaultIcon() {
    return _configBox?.get('defaultIcon') as String?;
  }

  Future<void> close() async {
    await _box?.close();
    await _configBox?.close();
    _box = null;
    _configBox = null;
  }
}
