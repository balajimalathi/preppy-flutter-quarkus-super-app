import 'package:core_env/core_env.dart';
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
  final env = ref.watch(appEnvProvider);
  final profile = ref.watch(profileServiceProvider);
  final storage = ref.watch(storageProvider);
  return switch (env.authBackend) {
    AuthBackend.firebase => FirebaseAuthService(
      profileService: profile,
      storage: storage,
    ),
    AuthBackend.supabase ||
    AuthBackend.keycloak ||
    AuthBackend.customApi => throw UnsupportedError(
      'Auth backend ${env.authBackend.name} is not implemented yet. '
      'Use AUTH_BACKEND=firebase or add an AuthContract implementation.',
    ),
  };
});
