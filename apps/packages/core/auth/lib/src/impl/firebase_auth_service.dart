import 'package:core_storage/core_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth_storage_keys.dart';
import '../contracts/auth_contract.dart';
import '../contracts/profile_contract.dart';
import '../models/app_profile.dart';
import '../models/auth_credentials.dart';
import '../models/auth_result.dart';
import '../models/signed_in_user.dart';

final class FirebaseAuthService implements AuthContract {
  FirebaseAuthService({
    required ProfileContract profileService,
    required StorageContract storage,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _profile = profileService,
       _storage = storage,
       _firebase = firebaseAuth ?? FirebaseAuth.instance,
       _google = googleSignIn ?? GoogleSignIn();

  final ProfileContract _profile;
  final StorageContract _storage;
  final FirebaseAuth _firebase;
  final GoogleSignIn _google;

  AuthErrorCode _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'user-disabled':
        return AuthErrorCode.userNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return AuthErrorCode.invalidCredentials;
      case 'email-already-in-use':
        return AuthErrorCode.emailAlreadyInUse;
      case 'network-request-failed':
        return AuthErrorCode.networkError;
      case 'user-token-expired':
      case 'invalid-user-token':
        return AuthErrorCode.tokenExpired;
      default:
        return AuthErrorCode.unknown;
    }
  }

  SignedInUser _mapUser(User user) {
    return SignedInUser(
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }

  @override
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    try {
      final UserCredential userCredential;
      switch (credentials) {
        case EmailCredentials(:final email, :final password):
          userCredential = await _firebase.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        case GoogleCredentials():
          final googleUser = await _google.signIn();
          if (googleUser == null) {
            return const AuthFailure(
              message: 'Google sign in cancelled',
              code: AuthErrorCode.cancelled,
            );
          }
          final googleAuth = await googleUser.authentication;
          final oauth = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          userCredential = await _firebase.signInWithCredential(oauth);
      }

      final user = userCredential.user;
      if (user == null) {
        return const AuthFailure(
          message: 'No user after sign-in',
          code: AuthErrorCode.unknown,
        );
      }

      await user.getIdToken();

      late final AppProfile profile;
      try {
        profile = await _profile.syncProfile();
      } catch (_) {
        await _firebase.signOut();
        await _google.signOut();
        return const AuthFailure(
          message: 'Could not sync profile with server',
          code: AuthErrorCode.profileFetchFailed,
        );
      }

      await _storage.write(AuthStorageKeys.userProfile, profile.toJsonString());

      return AuthSuccess(user: _mapUser(user), profile: profile);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(
        message: e.message ?? e.code,
        code: _mapFirebaseError(e),
      );
    } catch (e) {
      return AuthFailure(message: e.toString(), code: AuthErrorCode.unknown);
    }
  }

  @override
  Future<AuthResult> signUp(EmailCredentials credentials) async {
    try {
      final userCredential = await _firebase.createUserWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );
      final user = userCredential.user;
      if (user == null) {
        return const AuthFailure(
          message: 'No user after sign-up',
          code: AuthErrorCode.unknown,
        );
      }

      await user.getIdToken();

      late final AppProfile profile;
      try {
        profile = await _profile.syncProfile();
      } catch (_) {
        await _firebase.signOut();
        await _google.signOut();
        return const AuthFailure(
          message: 'Could not sync profile with server',
          code: AuthErrorCode.profileFetchFailed,
        );
      }

      await _storage.write(AuthStorageKeys.userProfile, profile.toJsonString());

      return AuthSuccess(user: _mapUser(user), profile: profile);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(
        message: e.message ?? e.code,
        code: _mapFirebaseError(e),
      );
    } catch (e) {
      return AuthFailure(message: e.toString(), code: AuthErrorCode.unknown);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebase.signOut();
    await _google.signOut();
    await _storage.delete(AuthStorageKeys.userProfile);
  }

  @override
  Future<String?> getValidToken() async {
    final user = _firebase.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken();
  }

  @override
  Stream<SignedInUser?> get authStateChanges {
    return _firebase.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return _mapUser(user);
    });
  }
}
