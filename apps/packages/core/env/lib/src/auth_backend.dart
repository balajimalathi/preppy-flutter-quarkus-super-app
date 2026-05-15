/// Compile-time auth IdP selection (`AUTH_BACKEND` dart-define).
enum AuthBackend {
  firebase,
  supabase,
  keycloak,
  customApi;

  static AuthBackend parse(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'supabase':
        return AuthBackend.supabase;
      case 'keycloak':
        return AuthBackend.keycloak;
      case 'custom':
      case 'customapi':
      case 'custom_api':
        return AuthBackend.customApi;
      case 'firebase':
      default:
        return AuthBackend.firebase;
    }
  }
}
