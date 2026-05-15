import '../models/app_profile.dart';

/// Backend profile — uses shared [Dio] + [authTokenProvider] for Bearer injection.
abstract interface class ProfileContract {
  /// `GET /users/me` — load or create profile for the current Firebase user (sign-in).
  Future<AppProfile> syncProfile();

  /// `GET /users/me` — refresh profile for boot / background sync.
  Future<AppProfile> fetchProfile();
}
