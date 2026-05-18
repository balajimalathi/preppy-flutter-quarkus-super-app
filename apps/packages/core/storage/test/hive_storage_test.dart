import 'dart:io';

import 'package:core_storage/src/impl/hive_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'helpers/storage_contract_suite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String boxName;

  runStorageContractTests(
    name: 'HiveStorage',
    setUpStorage: () async {
      tempDir = await Directory.systemTemp.createTemp('core_storage_hive_');
      Hive.init(tempDir.path);
      boxName = 'box_${DateTime.now().microsecondsSinceEpoch}';
    },
    tearDownStorage: () async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    },
    createStorage: () async => HiveStorage(boxName: boxName),
  );
}
