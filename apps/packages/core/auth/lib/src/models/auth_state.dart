import 'app_profile.dart';
import 'auth_result.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.profile});

  final AppProfile profile;
}

final class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}

final class AuthErrorState extends AuthState {
  const AuthErrorState({required this.message, required this.code});

  final String message;
  final AuthErrorCode code;
}
