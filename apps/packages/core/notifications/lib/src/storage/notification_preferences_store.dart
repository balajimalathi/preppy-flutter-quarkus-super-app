import 'package:hive_ce/hive.dart';

import '../models/channel_definition.dart';

/// Per-channel opt-in and initialization config stored in Hive.
class NotificationPreferencesStore {
  NotificationPreferencesStore({this.boxName = 'core_notifications_prefs'});

  /// Hive box name used for per-channel enabled flags.
  final String boxName;
  Box<bool>? _box;
  Box<dynamic>? _configBox;

  static const _keyPrefix = 'channel_enabled:';
  static const configBoxName = 'core_notifications_config';

  /// Opens all required Hive boxes.
  Future<void> open() async {
    _box = await Hive.openBox<bool>(boxName);
    _configBox = await Hive.openBox<dynamic>(configBoxName);
  }

  /// Returns whether notifications are enabled for [channelKey].
  bool isChannelEnabled(String channelKey) {
    final box = _box;
    if (box == null) {
      return true;
    }
    return box.get('$_keyPrefix$channelKey', defaultValue: true) ?? true;
  }

  /// Persists the enabled state for [channelKey].
  Future<void> setChannelEnabled(String channelKey, bool enabled) async {
    final box = _box;
    if (box == null) {
      throw StateError('NotificationPreferencesStore.open() was not called');
    }
    await box.put('$_keyPrefix$channelKey', enabled);
  }

  /// Removes the stored preference for [channelKey], restoring the default behavior.
  Future<void> clearChannel(String channelKey) async {
    final box = _box;
    if (box == null) {
      return;
    }
    await box.delete('$_keyPrefix$channelKey');
  }

  /// Persists the last local-initialization channel set and default icon.
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

  /// Returns the channel definitions saved during the last local initialization.
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

  /// Returns the default icon saved during the last local initialization.
  String? getSavedDefaultIcon() {
    return _configBox?.get('defaultIcon') as String?;
  }

  /// Closes all opened Hive boxes.
  Future<void> close() async {
    await _box?.close();
    await _configBox?.close();
    _box = null;
    _configBox = null;
  }
}
