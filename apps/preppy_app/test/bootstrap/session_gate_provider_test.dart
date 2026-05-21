import 'package:core_auth/core_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppy_app/bootstrap/router/session_gate_provider.dart';

void main() {
  AppProfile profile({required bool onboardingCompleted}) => AppProfile(
    profileId: 'profile-1',
    email: 'user@example.com',
    createdAt: DateTime.utc(2026, 5, 19),
    metadata: const {},
    onboardingCompleted: onboardingCompleted,
  );

  ProviderContainer containerFor(AsyncValue<AuthState> state) {
    return ProviderContainer(
      overrides: [sessionGateAuthStateProvider.overrideWithValue(state)],
    );
  }

  test('loading auth routes to splash', () {
    final container = containerFor(const AsyncLoading<AuthState>());
    addTearDown(container.dispose);

    expect(
      container.read(sessionGateProvider),
      const SessionGateState(target: SessionRouteTarget.splash),
    );
  });

  test('unauthenticated auth routes to login', () {
    final container = containerFor(
      const AsyncData<AuthState>(AuthUnauthenticated()),
    );
    addTearDown(container.dispose);

    expect(
      container.read(sessionGateProvider),
      const SessionGateState(target: SessionRouteTarget.login),
    );
  });

  test('authenticated incomplete profile routes to onboarding', () {
    final container = containerFor(
      AsyncData<AuthState>(
        AuthAuthenticated(profile: profile(onboardingCompleted: false)),
      ),
    );
    addTearDown(container.dispose);

    expect(
      container.read(sessionGateProvider),
      const SessionGateState(target: SessionRouteTarget.onboarding),
    );
  });

  test('authenticated complete profile routes to dashboard', () {
    final container = containerFor(
      AsyncData<AuthState>(
        AuthAuthenticated(profile: profile(onboardingCompleted: true)),
      ),
    );
    addTearDown(container.dispose);

    expect(
      container.read(sessionGateProvider),
      const SessionGateState(target: SessionRouteTarget.dashboard),
    );
  });
}
