import 'package:flutter/foundation.dart';

/// Post-sign-in user facts without any provider-specific identifiers.
@immutable
final class SignedInUser {
  const SignedInUser({
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isEmailVerified,
  });

  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
}
