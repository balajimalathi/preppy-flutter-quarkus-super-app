import 'package:core_auth/core_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionRouteTarget { splash, login, onboarding, dashboard }

@immutable
final class SessionGateState {
  const SessionGateState({required this.target});

  final SessionRouteTarget target;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionGateState && other.target == target;

  @override
  int get hashCode => target.hashCode;
}

final sessionGateAuthStateProvider = Provider<AsyncValue<AuthState>>((ref) {
  return ref.watch(authProvider);
});

final sessionGateProvider = Provider<SessionGateState>((ref) {
  final authAsync = ref.watch(sessionGateAuthStateProvider);
  return switch (authAsync) {
    AsyncLoading() => const SessionGateState(target: SessionRouteTarget.splash),
    AsyncError() => const SessionGateState(target: SessionRouteTarget.login),
    AsyncData(:final value) => switch (value) {
      AuthAuthenticated(:final profile) when !profile.onboardingCompleted =>
        const SessionGateState(target: SessionRouteTarget.onboarding),
      AuthAuthenticated() => const SessionGateState(
        target: SessionRouteTarget.dashboard,
      ),
      _ => const SessionGateState(target: SessionRouteTarget.login),
    },
  };
});
