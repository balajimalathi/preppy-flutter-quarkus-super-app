import 'signed_in_user.dart';
import 'app_profile.dart';

sealed class AuthResult {
  const AuthResult();
}

final class AuthSuccess extends AuthResult {
  const AuthSuccess({required this.user, required this.profile});

  final SignedInUser user;
  final AppProfile profile;
}

final class AuthFailure extends AuthResult {
  const AuthFailure({required this.message, required this.code});

  final String message;
  final AuthErrorCode code;
}

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
