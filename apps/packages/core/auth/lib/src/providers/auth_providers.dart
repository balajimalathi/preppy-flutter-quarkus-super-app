import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:riverpod/riverpod.dart';

import '../contracts/auth_contract.dart';
import '../contracts/profile_contract.dart';
import '../impl/firebase_auth_service.dart';
import '../impl/quarkus_profile_service.dart';

final profileServiceProvider = Provider<ProfileContract>((ref) {
  final dio = ref.watch(dioProvider);
  return QuarkusProfileService(dio);
});

final authServiceProvider = Provider<AuthContract>((ref) {
  return FirebaseAuthService(
    profileService: ref.watch(profileServiceProvider),
    storage: ref.watch(storageProvider),
  );
});
