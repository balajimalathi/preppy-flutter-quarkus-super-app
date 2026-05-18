import 'signed_in_user.dart';
import 'app_profile.dart';

/// Result of a completed authentication attempt.
sealed class AuthResult {
  const AuthResult();
}

/// Authentication succeeded and both identity and profile data are available.
final class AuthSuccess extends AuthResult {
  const AuthSuccess({required this.user, required this.profile});

  final SignedInUser user;
  final AppProfile profile;
}

/// Authentication failed with a user-facing [message] and typed [code].
final class AuthFailure extends AuthResult {
  const AuthFailure({required this.message, required this.code});

  final String message;
  final AuthErrorCode code;
}

/// High-level reasons an authentication flow can fail.
enum AuthErrorCode {
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  networkError,
  profileFetchFailed,
  tokenExpired,
  cancelled,
  unknown,
}
