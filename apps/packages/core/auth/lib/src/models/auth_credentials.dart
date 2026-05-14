sealed class AuthCredentials {
  const AuthCredentials();
}

final class EmailCredentials extends AuthCredentials {
  const EmailCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

/// Google Sign-In is driven by the platform SDK inside [AuthContract] impl.
final class GoogleCredentials extends AuthCredentials {
  const GoogleCredentials();
}
