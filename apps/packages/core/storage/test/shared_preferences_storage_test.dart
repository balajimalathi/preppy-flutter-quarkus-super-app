import 'package:core_storage/src/impl/shared_preferences_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/storage_contract_suite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  runStorageContractTests(
    name: 'SharedPreferencesStorage',
    setUpStorage: () async {
      SharedPreferences.setMockInitialValues({});
    },
    createStorage: () async {
      final prefs = await SharedPreferences.getInstance();
      return SharedPreferencesStorage(prefs);
    },
  );
}
