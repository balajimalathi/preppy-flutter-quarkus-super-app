import 'app_profile.dart';
import 'auth_result.dart';

/// App-wide authentication state exposed by [AuthNotifier].
sealed class AuthState {
  const AuthState();
}

/// No active authenticated session exists.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// The user is signed in and a profile is available.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.profile});

  final AppProfile profile;
}

/// The previous session is no longer valid and sign-in is required again.
final class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}

/// Auth bootstrapping or refresh failed in a recoverable way.
final class AuthErrorState extends AuthState {
  const AuthErrorState({required this.message, required this.code});

  final String message;
  final AuthErrorCode code;
}
