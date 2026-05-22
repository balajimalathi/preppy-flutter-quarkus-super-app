import 'dart:async';
import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:riverpod/riverpod.dart';

import 'auth_storage_keys.dart';
import 'models/app_profile.dart';
import 'models/auth_credentials.dart';
import 'models/auth_result.dart';
import 'models/auth_state.dart';
import 'impl/profile_exceptions.dart';
import 'providers/auth_providers.dart';

/// Boot hydration, background profile refresh, and sign-in / sign-out.
final class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return _hydrate();
  }

  Future<AuthState> _hydrate() async {
    final storage = ref.read(storageProvider);
    final auth = ref.read(authServiceProvider);

    final token = await auth.getValidToken();
    if (token == null || token.isEmpty) {
      return const AuthUnauthenticated();
    }

    final cachedRaw = await storage.read(AuthStorageKeys.userProfile);
    if (cachedRaw != null && cachedRaw.isNotEmpty) {
      try {
        final map = jsonDecode(cachedRaw) as Map<String, dynamic>;
        final profile = AppProfile.fromJson(map);
        unawaited(_refreshProfileInBackground(profile));
        return AuthAuthenticated(profile: profile);
      } on Object {
        await storage.delete(AuthStorageKeys.userProfile);
      }
    }

    final profileSvc = ref.read(profileServiceProvider);
    try {
      final profile = await profileSvc.fetchProfile();
      await storage.write(AuthStorageKeys.userProfile, profile.toJsonString());
      return AuthAuthenticated(profile: profile);
    } on ProfileFetchException catch (e) {
      if (e.isAuthFailure) {
        await auth.signOut();
      }
      return const AuthUnauthenticated();
    } on Object {
      await auth.signOut();
      return const AuthUnauthenticated();
    }
  }

  /// Re-fetches `/v1/users/me` and updates auth state without a loading phase.
  Future<void> refreshAuthenticatedProfile() async {
    if (state case AsyncData(:final value) when value is AuthAuthenticated) {
      try {
        final profileSvc = ref.read(profileServiceProvider);
        final fresh = await profileSvc.fetchProfile();
        final storage = ref.read(storageProvider);
        await storage.write(AuthStorageKeys.userProfile, fresh.toJsonString());
        state = AsyncData(AuthAuthenticated(profile: fresh));
      } on Object {
        // Keep the current profile when refresh fails.
      }
    }
  }

  Future<void> _refreshProfileInBackground(AppProfile cached) async {
    try {
      final profileSvc = ref.read(profileServiceProvider);
      final fresh = await profileSvc.fetchProfile();
      if (fresh != cached) {
        final storage = ref.read(storageProvider);
        await storage.write(AuthStorageKeys.userProfile, fresh.toJsonString());
        state = AsyncData(AuthAuthenticated(profile: fresh));
      }
    } on Object {
      // Cached profile remains valid.
    }
  }

  Future<void> signIn(AuthCredentials credentials) async {
    state = const AsyncLoading();
    final result = await ref.read(authServiceProvider).signIn(credentials);
    state = switch (result) {
      AuthSuccess(:final profile) => AsyncData(
        AuthAuthenticated(profile: profile),
      ),
      AuthFailure(:final message, :final code) => AsyncData(
        AuthErrorState(message: message, code: code),
      ),
    };
  }

  Future<void> signUp(EmailCredentials credentials) async {
    state = const AsyncLoading();
    final result = await ref.read(authServiceProvider).signUp(credentials);
    state = switch (result) {
      AuthSuccess(:final profile) => AsyncData(
        AuthAuthenticated(profile: profile),
      ),
      AuthFailure(:final message, :final code) => AsyncData(
        AuthErrorState(message: message, code: code),
      ),
    };
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = const AsyncData(AuthUnauthenticated());
  }

  Future<void> clearError() async {
    switch (state) {
      case AsyncData(:final value):
        if (value is AuthErrorState) {
          state = const AsyncData(AuthUnauthenticated());
        }
      default:
        break;
    }
  }
}

/// App-wide authentication + profile state.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Quarkus `profileId` when authenticated; null otherwise.
final profileIdProvider = Provider<String?>((ref) {
  final async = ref.watch(authProvider);
  return switch (async) {
    AsyncData(:final value) => switch (value) {
      AuthAuthenticated(:final profile) => profile.profileId,
      _ => null,
    },
    _ => null,
  };
});
