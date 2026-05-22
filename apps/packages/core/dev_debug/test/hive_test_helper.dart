import 'dart:io';

import 'package:hive_ce/hive.dart';

/// Initializes Hive in a temp directory for store tests.
Future<Directory> initHiveForTest() async {
  final dir = await Directory.systemTemp.createTemp('core_notifications_test_');
  Hive.init(dir.path);
  return dir;
}

Future<void> tearDownHiveForTest(Directory dir) async {
  await Hive.close();
  await dir.delete(recursive: true);
}

Future<void> deleteBoxIfOpen(String name) async {
  if (Hive.isBoxOpen(name)) {
    final box = Hive.box(name);
    await box.clear();
    await box.close();
  }
}
