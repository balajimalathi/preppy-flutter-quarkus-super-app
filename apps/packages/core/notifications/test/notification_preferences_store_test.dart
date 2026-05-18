import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hive_test_helper.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await initHiveForTest();
  });

  tearDownAll(() async {
    await tearDownHiveForTest(tempDir);
  });

  tearDown(() async {
    await deleteBoxIfOpen('test_prefs');
    await deleteBoxIfOpen(NotificationPreferencesStore.configBoxName);
  });

  group('NotificationPreferencesStore', () {
    test('isChannelEnabled defaults to true before open', () {
      final store = NotificationPreferencesStore(boxName: 'test_prefs');
      expect(store.isChannelEnabled('alerts'), isTrue);
    });

    test('setChannelEnabled persists opt-out', () async {
      final store = NotificationPreferencesStore(boxName: 'test_prefs');
      await store.open();
      await store.setChannelEnabled('alerts', false);
      expect(store.isChannelEnabled('alerts'), isFalse);
      await store.close();
    });

    test('clearChannel removes override and defaults to enabled', () async {
      final store = NotificationPreferencesStore(boxName: 'test_prefs');
      await store.open();
      await store.setChannelEnabled('alerts', false);
      await store.clearChannel('alerts');
      expect(store.isChannelEnabled('alerts'), isTrue);
      await store.close();
    });

    test('setChannelEnabled throws when store is not open', () async {
      final store = NotificationPreferencesStore(boxName: 'test_prefs');
      expect(
        () => store.setChannelEnabled('alerts', false),
        throwsA(isA<StateError>()),
      );
    });

    test('saveInitializationConfig round-trips channels and icon', () async {
      final store = NotificationPreferencesStore(boxName: 'test_prefs');
      await store.open();

      const channels = [
        NotificationChannelDefinition(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Test',
          defaultLayout: NotificationLayout.BigPicture,
        ),
      ];
      await store.saveInitializationConfig(
        channels,
        'resource://mipmap/ic_launcher',
      );

      expect(store.getSavedChannels(), hasLength(1));
      expect(store.getSavedChannels().first.channelKey, 'alerts');
      expect(
        store.getSavedChannels().first.defaultLayout,
        NotificationLayout.BigPicture,
      );
      expect(store.getSavedDefaultIcon(), 'resource://mipmap/ic_launcher');

      await store.close();
    });

    test('getSavedChannels returns empty when config box is not open', () {
      final store = NotificationPreferencesStore(boxName: 'test_prefs');
      expect(store.getSavedChannels(), isEmpty);
      expect(store.getSavedDefaultIcon(), isNull);
    });
  });
}
