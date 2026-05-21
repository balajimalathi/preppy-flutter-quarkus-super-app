import 'dart:convert';

import 'package:core_auth/core_auth.dart';
import 'package:core_auth/src/auth_storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

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
      expect(profile.onboardingCompletedAt, DateTime.parse('2026-05-19T10:00:00Z'));
      expect(
        AppProfile.fromJson(profile.toJson()),
        profile,
      );
    });

    test('returns unauthenticated when token is null', () async {
      final storage = InMemoryStorage();
      final auth = FakeAuthService(token: null);
      final profile = FakeProfileService();

      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: storage,
          auth: auth,
          profile: profile,
        ),
      );
      addTearDown(container.dispose);

      final state = await container.read(authProvider.future);
      expect(state, isA<AuthUnauthenticated>());
      expect(profile.fetchCallCount, 0);
    });

    test('returns authenticated from valid cache', () async {
      final storage = InMemoryStorage();
      await storage.write(
        AuthStorageKeys.userProfile,
        sampleProfile.toJsonString(),
      );
      final auth = FakeAuthService(token: 'token');
      final profile = FakeProfileService();

      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: storage,
          auth: auth,
          profile: profile,
        ),
      );
      addTearDown(container.dispose);

      final state = await container.read(authProvider.future);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).profile, sampleProfile);
    });

    test('corrupt cache is cleared then profile is fetched', () async {
      final storage = InMemoryStorage();
      await storage.write(AuthStorageKeys.userProfile, 'not-json');
      final auth = FakeAuthService(token: 'token');
      final profile = FakeProfileService();

      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: storage,
          auth: auth,
          profile: profile,
        ),
      );
      addTearDown(container.dispose);

      final state = await container.read(authProvider.future);
      expect(state, isA<AuthAuthenticated>());
      expect(profile.fetchCallCount, 1);
      expect(await storage.read(AuthStorageKeys.userProfile), isNotNull);
    });

    test('fetches profile when no cache', () async {
      final storage = InMemoryStorage();
      final auth = FakeAuthService(token: 'token');
      final profile = FakeProfileService();

      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: storage,
          auth: auth,
          profile: profile,
        ),
      );
      addTearDown(container.dispose);

      final state = await container.read(authProvider.future);
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
      final storage = InMemoryStorage();
      final auth = FakeAuthService(token: 'token');
      final profile = FakeProfileService(
        onFetch: () => throw profileAuthException(),
      );

      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: storage,
          auth: auth,
          profile: profile,
        ),
      );
      addTearDown(container.dispose);

      final state = await container.read(authProvider.future);
      expect(state, isA<AuthUnauthenticated>());
      expect(auth.signOutCallCount, 1);
    });

    test('generic fetch error signs out', () async {
      final storage = InMemoryStorage();
      final auth = FakeAuthService(token: 'token');
      final profile = FakeProfileService(
        onFetch: () => throw Exception('boom'),
      );

      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: storage,
          auth: auth,
          profile: profile,
        ),
      );
      addTearDown(container.dispose);

      final state = await container.read(authProvider.future);
      expect(state, isA<AuthUnauthenticated>());
      expect(auth.signOutCallCount, 1);
    });

    test(
      'background refresh updates profile when fetch returns new data',
      () async {
        final storage = InMemoryStorage();
        await storage.write(
          AuthStorageKeys.userProfile,
          sampleProfile.toJsonString(),
        );
        final auth = FakeAuthService(token: 'token');
        final profile = FakeProfileService(
          onFetch: () async => _updatedProfile,
        );

        final container = ProviderContainer(
          overrides: authTestOverrides(
            storage: storage,
            auth: auth,
            profile: profile,
          ),
        );
        addTearDown(container.dispose);

        await container.read(authProvider.future);
        await pumpEventQueue(times: 3);

        final async = container.read(authProvider);
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
      final container = _containerWithSession();
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await container
          .read(authProvider.notifier)
          .signIn(const EmailCredentials(email: 'a@b.com', password: 'secret'));

      final state = container.read(authProvider).requireValue;
      expect(state, isA<AuthAuthenticated>());
    });

    test('signIn failure sets error state', () async {
      final auth = FakeAuthService(
        token: null,
        onSignIn: (_) async => const AuthFailure(
          message: 'Invalid',
          code: AuthErrorCode.invalidCredentials,
        ),
      );
      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: InMemoryStorage(),
          auth: auth,
          profile: FakeProfileService(),
        ),
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await container
          .read(authProvider.notifier)
          .signIn(const EmailCredentials(email: 'a@b.com', password: 'wrong'));

      final state = container.read(authProvider).requireValue;
      expect(state, isA<AuthErrorState>());
      expect((state as AuthErrorState).code, AuthErrorCode.invalidCredentials);
    });

    test('signUp success sets authenticated', () async {
      final container = _containerWithSession();
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await container
          .read(authProvider.notifier)
          .signUp(
            const EmailCredentials(email: 'new@b.com', password: 'secret'),
          );

      expect(
        container.read(authProvider).requireValue,
        isA<AuthAuthenticated>(),
      );
    });

    test('signUp failure sets error state', () async {
      final auth = FakeAuthService(
        token: null,
        onSignUp: (_) async => const AuthFailure(
          message: 'Taken',
          code: AuthErrorCode.emailAlreadyInUse,
        ),
      );
      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: InMemoryStorage(),
          auth: auth,
          profile: FakeProfileService(),
        ),
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await container
          .read(authProvider.notifier)
          .signUp(const EmailCredentials(email: 'x@y.com', password: 'p'));

      final state = container.read(authProvider).requireValue;
      expect(state, isA<AuthErrorState>());
      expect((state as AuthErrorState).code, AuthErrorCode.emailAlreadyInUse);
    });

    test('signOut sets unauthenticated', () async {
      final container = _containerWithSession();
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).signOut();

      expect(
        container.read(authProvider).requireValue,
        isA<AuthUnauthenticated>(),
      );
    });

    test('clearError from error state sets unauthenticated', () async {
      final auth = FakeAuthService(
        token: null,
        onSignIn: (_) async =>
            const AuthFailure(message: 'fail', code: AuthErrorCode.unknown),
      );
      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: InMemoryStorage(),
          auth: auth,
          profile: FakeProfileService(),
        ),
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      await container
          .read(authProvider.notifier)
          .signIn(const EmailCredentials(email: 'a@b.com', password: 'x'));

      await container.read(authProvider.notifier).clearError();

      expect(
        container.read(authProvider).requireValue,
        isA<AuthUnauthenticated>(),
      );
    });

    test('clearError is no-op when authenticated', () async {
      final container = _containerWithSession();
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).clearError();

      expect(
        container.read(authProvider).requireValue,
        isA<AuthAuthenticated>(),
      );
    });
  });

  group('profileIdProvider', () {
    test('returns profileId when authenticated', () async {
      final container = _containerWithSession();
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      expect(container.read(profileIdProvider), sampleProfile.profileId);
    });

    test('returns null when unauthenticated', () async {
      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: InMemoryStorage(),
          auth: FakeAuthService(token: null),
          profile: FakeProfileService(),
        ),
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      expect(container.read(profileIdProvider), isNull);
    });

    test('returns null on error state', () async {
      final auth = FakeAuthService(
        token: null,
        onSignIn: (_) async =>
            const AuthFailure(message: 'err', code: AuthErrorCode.unknown),
      );
      final container = ProviderContainer(
        overrides: authTestOverrides(
          storage: InMemoryStorage(),
          auth: auth,
          profile: FakeProfileService(),
        ),
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      await container
          .read(authProvider.notifier)
          .signIn(const EmailCredentials(email: 'a@b.com', password: 'x'));

      expect(container.read(profileIdProvider), isNull);
    });
  });
}

ProviderContainer _containerWithSession() {
  final storage = InMemoryStorage();
  return ProviderContainer(
    overrides: authTestOverrides(
      storage: storage,
      auth: FakeAuthService(token: 'token'),
      profile: FakeProfileService(),
    ),
  );
}
