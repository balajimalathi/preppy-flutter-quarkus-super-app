import 'package:core_storage/src/impl/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/storage_contract_suite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  runStorageContractTests(
    name: 'SecureStorage',
    setUpStorage: () async {
      FlutterSecureStorage.setMockInitialValues({});
    },
    createStorage: () async => SecureStorage(),
  );
}
