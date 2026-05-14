import '../models/auth_credentials.dart';
import '../models/auth_result.dart';
import '../models/signed_in_user.dart';

/// Firebase (or any IdP) — credentials only; profile sync is orchestrated here.
abstract interface class AuthContract {
  Future<AuthResult> signIn(AuthCredentials credentials);

  Future<AuthResult> signUp(EmailCredentials credentials);

  Future<void> signOut();

  /// Returns a fresh ID token when signed in; otherwise null.
  Future<String?> getValidToken();

  Stream<SignedInUser?> get authStateChanges;
}
