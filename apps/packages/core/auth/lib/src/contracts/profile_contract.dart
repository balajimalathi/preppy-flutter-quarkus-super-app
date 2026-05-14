import '../models/app_profile.dart';

/// Backend profile — uses shared [Dio] + [authTokenProvider] for Bearer injection.
abstract interface class ProfileContract {
  /// POST `/v1/auth/profile` — create or load profile for the current Firebase user.
  Future<AppProfile> syncProfile();

  /// GET `/v1/auth/profile` — refresh profile for boot / background sync.
  Future<AppProfile> fetchProfile();
}
