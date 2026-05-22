import 'dart:io';

import 'package:core_dev_debug/core_dev_debug.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

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
    await deleteBoxIfOpen('test_push_log');
    await deleteBoxIfOpen('test_push_log_corrupt');
  });

  group('PushPayloadHistoryStore', () {
    test('loadAll returns empty when not opened', () async {
      final store = PushPayloadHistoryStore(boxName: 'test_push_log');
      expect(await store.loadAll(), isEmpty);
    });

    test('replaceAll and loadAll round-trip events', () async {
      final store = PushPayloadHistoryStore(boxName: 'test_push_log');
      await store.open();

      final events = [
        PushReceiveEvent(
          kind: PushReceiveKind.created,
          summary: 'first',
          raw: {'title': 'A'},
        ),
        PushReceiveEvent(
          kind: PushReceiveKind.displayed,
          summary: 'second',
          raw: {'title': 'B'},
        ),
      ];
      await store.replaceAll(events);

      final loaded = await store.loadAll();
      expect(loaded, hasLength(2));
      expect(loaded[0].summary, 'first');
      expect(loaded[1].kind, PushReceiveKind.displayed);

      await store.close();
    });

    test('replaceAll trims to maxStoredEvents', () async {
      final store = PushPayloadHistoryStore(boxName: 'test_push_log');
      await store.open();

      final events = List.generate(
        PushPayloadHistoryStore.maxStoredEvents + 5,
        (i) => PushReceiveEvent(
          kind: PushReceiveKind.silentData,
          summary: 'event-$i',
          raw: const {},
        ),
      );
      await store.replaceAll(events);

      final loaded = await store.loadAll();
      expect(loaded, hasLength(PushPayloadHistoryStore.maxStoredEvents));
      expect(loaded.first.summary, 'event-0');

      await store.close();
    });

    test('clear removes persisted events', () async {
      final store = PushPayloadHistoryStore(boxName: 'test_push_log');
      await store.open();
      await store.replaceAll([
        PushReceiveEvent(
          kind: PushReceiveKind.action,
          summary: 'tap',
          raw: const {},
        ),
      ]);
      await store.clear();
      expect(await store.loadAll(), isEmpty);
      await store.close();
    });

    test('loadAll returns empty for corrupt JSON', () async {
      const boxName = 'test_push_log_corrupt';
      final store = PushPayloadHistoryStore(boxName: boxName);
      await store.open();
      final box = Hive.box<String>(boxName);
      await box.put('events', 'not-valid-json');
      expect(await store.loadAll(), isEmpty);
      await store.close();
    });
  });
}
