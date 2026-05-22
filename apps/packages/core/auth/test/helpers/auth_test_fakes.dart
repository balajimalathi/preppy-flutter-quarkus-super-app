import 'package:core_auth/core_auth.dart';
import 'package:core_auth/src/impl/profile_exceptions.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart';

final _sampleCreatedAt = DateTime.utc(2024, 6, 1, 12, 0, 0);

final sampleProfile = AppProfile(
  profileId: 'profile-1',
  email: 'user@example.com',
  fullName: 'Test User',
  createdAt: _sampleCreatedAt,
  metadata: const {'role': 'student'},
);

Map<String, dynamic> get sampleProfileJson => {
  'profileId': sampleProfile.profileId,
  'email': sampleProfile.email,
  'fullName': sampleProfile.fullName,
  'createdAt': sampleProfile.createdAt.toIso8601String(),
  'metadata': sampleProfile.metadata,
};

final class InMemoryStorage implements StorageContract {
  final Map<String, String> _store = {};

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;
}

final class FakeAuthService implements AuthContract {
  FakeAuthService({
    this.token,
    Future<AuthResult> Function(AuthCredentials credentials)? onSignIn,
    Future<AuthResult> Function(EmailCredentials credentials)? onSignUp,
  }) : _onSignIn = onSignIn,
       _onSignUp = onSignUp;

  String? token;
  final Future<AuthResult> Function(AuthCredentials credentials)? _onSignIn;
  final Future<AuthResult> Function(EmailCredentials credentials)? _onSignUp;
  int signOutCallCount = 0;

  @override
  Stream<SignedInUser?> get authStateChanges => const Stream.empty();

  @override
  Future<String?> getValidToken() async => token;

  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    final onSignIn = _onSignIn;
    if (onSignIn != null) {
      return onSignIn(credentials);
    }
    return AuthSuccess(
      user: const SignedInUser(
        email: 'user@example.com',
        isEmailVerified: true,
      ),
      profile: sampleProfile,
    );
  }

  @override
  Future<AuthResult> signUp(EmailCredentials credentials) async {
    final onSignUp = _onSignUp;
    if (onSignUp != null) {
      return onSignUp(credentials);
    }
    return AuthSuccess(
      user: SignedInUser(email: credentials.email, isEmailVerified: false),
      profile: sampleProfile,
    );
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    token = null;
  }
}

final class FakeProfileService implements ProfileContract {
  FakeProfileService({
    Future<AppProfile> Function()? onFetch,
    Future<AppProfile> Function()? onSync,
  }) : _onFetch = onFetch,
       _onSync = onSync;

  final Future<AppProfile> Function()? _onFetch;
  final Future<AppProfile> Function()? _onSync;
  int fetchCallCount = 0;
  int syncCallCount = 0;

  @override
  Future<AppProfile> fetchProfile() async {
    fetchCallCount++;
    final onFetch = _onFetch;
    if (onFetch != null) {
      return onFetch();
    }
    return sampleProfile;
  }

  @override
  Future<AppProfile> syncProfile() async {
    syncCallCount++;
    final onSync = _onSync;
    if (onSync != null) {
      return onSync();
    }
    return sampleProfile;
  }
}

List<Override> authTestOverrides({
  required InMemoryStorage storage,
  required FakeAuthService auth,
  required FakeProfileService profile,
}) {
  return [
    storageProvider.overrideWithValue(storage),
    authServiceProvider.overrideWithValue(auth),
    profileServiceProvider.overrideWithValue(profile),
  ];
}

ProfileFetchException profileAuthException([String message = 'Unauthorized']) {
  return ProfileFetchException(message, statusCode: 401);
}

/// Shared [ProviderContainer] setup for auth notifier tests.
class AuthTestHarness {
  AuthTestHarness({
    InMemoryStorage? storage,
    FakeAuthService? auth,
    FakeProfileService? profile,
    List<Override> extraOverrides = const [],
  }) : container = ProviderContainer(
         overrides: [
           ...authTestOverrides(
             storage: storage ?? InMemoryStorage(),
             auth: auth ?? FakeAuthService(token: 'token'),
             profile: profile ?? FakeProfileService(),
           ),
           ...extraOverrides,
         ],
       );

  final ProviderContainer container;

  void dispose() => container.dispose();

  Future<AuthState> readAuth() => container.read(authProvider.future);

  AuthNotifier get notifier => container.read(authProvider.notifier);

  AuthState get current => container.read(authProvider).requireValue;
}
