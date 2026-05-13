import 'package:riverpod/riverpod.dart';

import 'impl/hive_storage.dart';
import 'impl/secure_storage.dart';
import 'impl/shared_preferences_storage.dart';
import 'shared_preferences_singleton.dart';
import 'storage_contract.dart';

final storageProvider = Provider<StorageContract>((ref) {
  return HiveStorage();
});

final secureStorageProvider = Provider<StorageContract>((ref) {
  return SecureStorage();
});

final sharedPreferencesStorageProvider = Provider<StorageContract>((ref) {
  return SharedPreferencesStorage(SharedPreferencesSingleton.instance);
});
