import 'dart:convert';

import 'package:core_auth/core_auth.dart';
import 'package:core_auth/src/auth_storage_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_fakes.dart';

final _updatedProfile = AppProfile(
  profileId: 'profile-2',
  email: 'updated@example.com',
  createdAt: DateTime.utc(2024, 7, 1),
  metadata: const {},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier hydration', () {
    test('profile parses backend onboarding completion fields', () {
      final profile = AppProfile.fromJson({
        ...sampleProfileJson,
        'onboardingCompleted': true,
        'onboardingCompletedAt': '2026-05-19T10:00:00Z',
      });

      expect(profile.onboardingCompleted, isTrue);
      expect(
        profile.onboardingCompletedAt,
        DateTime.parse('2026-05-19T10:00:00Z'),
      );
      expect(AppProfile.fromJson(profile.toJson()), profile);
    });

    test('returns unauthenticated when token is null', () async {
      final profile = FakeProfileService();
      final harness = AuthTestHarness(
        auth: FakeAuthService(token: null),
        profile: profile,
      );
      addTearDown(harness.dispose);

      final state = await harness.readAuth();
      expect(state, isA<AuthUnauthenticated>());
      expect(profile.fetchCallCount, 0);
    });

    test('returns authenticated from valid cache', () async {
      final storage = InMemoryStorage();
      await storage.write(
        AuthStorageKeys.userProfile,
        sampleProfile.toJsonString(),
      );
      final profile = FakeProfileService();
      final harness = AuthTestHarness(storage: storage, profile: profile);
      addTearDown(harness.dispose);

      final state = await harness.readAuth();
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).profile, sampleProfile);
    });

    test('corrupt cache is cleared then profile is fetched', () async {
      final storage = InMemoryStorage();
      await storage.write(AuthStorageKeys.userProfile, 'not-json');
      final profile = FakeProfileService();
      final harness = AuthTestHarness(storage: storage, profile: profile);
      addTearDown(harness.dispose);

      final state = await harness.readAuth();
      expect(state, isA<AuthAuthenticated>());
      expect(profile.fetchCallCount, 1);
      expect(await storage.read(AuthStorageKeys.userProfile), isNotNull);
    });

    test('fetches profile when no cache', () async {
      final storage = InMemoryStorage();
      final profile = FakeProfileService();
      final harness = AuthTestHarness(storage: storage, profile: profile);
      addTearDown(harness.dispose);

      final state = await harness.readAuth();
      expect(state, isA<AuthAuthenticated>());
      expect(profile.fetchCallCount, 1);
      final cached = await storage.read(AuthStorageKeys.userProfile);
      expect(cached, isNotNull);
      expect(
        AppProfile.fromJson(jsonDecode(cached!) as Map<String, dynamic>),
        sampleProfile,
      );
    });

    test('profile 401 signs out and returns unauthenticated', () async {
      final harness = AuthTestHarness(
        profile: FakeProfileService(
          onFetch: () => throw profileAuthException(),
        ),
      );
      addTearDown(harness.dispose);

      final state = await harness.readAuth();
      expect(state, isA<AuthUnauthenticated>());
      expect(
        harness.container.read(authServiceProvider),
        isA<FakeAuthService>(),
      );
      expect(
        (harness.container.read(authServiceProvider) as FakeAuthService)
            .signOutCallCount,
        1,
      );
    });

    test('generic fetch error signs out', () async {
      final harness = AuthTestHarness(
        profile: FakeProfileService(onFetch: () => throw Exception('boom')),
      );
      addTearDown(harness.dispose);

      final state = await harness.readAuth();
      expect(state, isA<AuthUnauthenticated>());
      expect(
        (harness.container.read(authServiceProvider) as FakeAuthService)
            .signOutCallCount,
        1,
      );
    });

    test(
      'background refresh updates profile when fetch returns new data',
      () async {
        final storage = InMemoryStorage();
        await storage.write(
          AuthStorageKeys.userProfile,
          sampleProfile.toJsonString(),
        );
        final harness = AuthTestHarness(
          storage: storage,
          profile: FakeProfileService(onFetch: () async => _updatedProfile),
        );
        addTearDown(harness.dispose);

        await harness.readAuth();
        await pumpEventQueue(times: 3);

        final async = harness.container.read(authProvider);
        expect(async.hasValue, isTrue);
        final state = async.requireValue;
        expect(state, isA<AuthAuthenticated>());
        expect((state as AuthAuthenticated).profile, _updatedProfile);
        final cached = await storage.read(AuthStorageKeys.userProfile);
        expect(
          AppProfile.fromJson(jsonDecode(cached!) as Map<String, dynamic>),
          _updatedProfile,
        );
      },
    );
  });

  group('AuthNotifier mutations', () {
    test('signIn success sets authenticated', () async {
      final harness = AuthTestHarness();
      addTearDown(harness.dispose);
      await harness.readAuth();

      await harness.notifier.signIn(
        const EmailCredentials(email: 'a@b.com', password: 'secret'),
      );

      expect(harness.current, isA<AuthAuthenticated>());
    });

    test('signIn failure sets error state', () async {
      final harness = AuthTestHarness(
        auth: FakeAuthService(
          token: null,
          onSignIn: (_) async => const AuthFailure(
            message: 'Invalid',
            code: AuthErrorCode.invalidCredentials,
          ),
        ),
      );
      addTearDown(harness.dispose);
      await harness.readAuth();

      await harness.notifier.signIn(
        const EmailCredentials(email: 'a@b.com', password: 'wrong'),
      );

      final state = harness.current;
      expect(state, isA<AuthErrorState>());
      expect((state as AuthErrorState).code, AuthErrorCode.invalidCredentials);
    });

    test('signUp success sets authenticated', () async {
      final harness = AuthTestHarness();
      addTearDown(harness.dispose);
      await harness.readAuth();

      await harness.notifier.signUp(
        const EmailCredentials(email: 'new@b.com', password: 'secret'),
      );

      expect(harness.current, isA<AuthAuthenticated>());
    });

    test('signUp failure sets error state', () async {
      final harness = AuthTestHarness(
        auth: FakeAuthService(
          token: null,
          onSignUp: (_) async => const AuthFailure(
            message: 'Taken',
            code: AuthErrorCode.emailAlreadyInUse,
          ),
        ),
      );
      addTearDown(harness.dispose);
      await harness.readAuth();

      await harness.notifier.signUp(
        const EmailCredentials(email: 'x@y.com', password: 'p'),
      );

      final state = harness.current;
      expect(state, isA<AuthErrorState>());
      expect((state as AuthErrorState).code, AuthErrorCode.emailAlreadyInUse);
    });

    test('signOut sets unauthenticated', () async {
      final harness = AuthTestHarness();
      addTearDown(harness.dispose);
      await harness.readAuth();

      await harness.notifier.signOut();

      expect(harness.current, isA<AuthUnauthenticated>());
    });

    test('clearError from error state sets unauthenticated', () async {
      final harness = AuthTestHarness(
        auth: FakeAuthService(
          token: null,
          onSignIn: (_) async =>
              const AuthFailure(message: 'fail', code: AuthErrorCode.unknown),
        ),
      );
      addTearDown(harness.dispose);
      await harness.readAuth();
      await harness.notifier.signIn(
        const EmailCredentials(email: 'a@b.com', password: 'x'),
      );

      await harness.notifier.clearError();

      expect(harness.current, isA<AuthUnauthenticated>());
    });

    test('clearError is no-op when authenticated', () async {
      final harness = AuthTestHarness();
      addTearDown(harness.dispose);
      await harness.readAuth();

      await harness.notifier.clearError();

      expect(harness.current, isA<AuthAuthenticated>());
    });
  });

  group('refreshAuthenticatedProfile', () {
    test('updates cached profile without entering loading', () async {
      final storage = InMemoryStorage();
      await storage.write(
        AuthStorageKeys.userProfile,
        sampleProfile.toJsonString(),
      );
      final harness = AuthTestHarness(
        storage: storage,
        profile: FakeProfileService(
          onFetch: () async => AppProfile(
            profileId: _updatedProfile.profileId,
            email: _updatedProfile.email,
            createdAt: _updatedProfile.createdAt,
            metadata: _updatedProfile.metadata,
            onboardingCompleted: true,
            onboardingCompletedAt: DateTime.utc(2026, 5, 19),
          ),
        ),
      );
      addTearDown(harness.dispose);
      await harness.readAuth();

      await harness.notifier.refreshAuthenticatedProfile();

      final async = harness.container.read(authProvider);
      expect(async.isLoading, isFalse);
      expect(async.requireValue, isA<AuthAuthenticated>());
      final authenticated = async.requireValue as AuthAuthenticated;
      expect(authenticated.profile.onboardingCompleted, isTrue);
      expect(authenticated.profile.email, _updatedProfile.email);
    });
  });

  group('profileIdProvider', () {
    test('returns profileId when authenticated', () async {
      final harness = AuthTestHarness();
      addTearDown(harness.dispose);
      await harness.readAuth();

      expect(
        harness.container.read(profileIdProvider),
        sampleProfile.profileId,
      );
    });

    test('returns null when unauthenticated', () async {
      final harness = AuthTestHarness(auth: FakeAuthService(token: null));
      addTearDown(harness.dispose);
      await harness.readAuth();

      expect(harness.container.read(profileIdProvider), isNull);
    });

    test('returns null on error state', () async {
      final harness = AuthTestHarness(
        auth: FakeAuthService(
          token: null,
          onSignIn: (_) async =>
              const AuthFailure(message: 'err', code: AuthErrorCode.unknown),
        ),
      );
      addTearDown(harness.dispose);
      await harness.readAuth();
      await harness.notifier.signIn(
        const EmailCredentials(email: 'a@b.com', password: 'x'),
      );

      expect(harness.container.read(profileIdProvider), isNull);
    });
  });
}
