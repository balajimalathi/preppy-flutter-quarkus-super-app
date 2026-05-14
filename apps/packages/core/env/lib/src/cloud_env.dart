import 'package:riverpod/riverpod.dart';

/// Compile-time configuration for optional cloud backends (Supabase, Neon, buckets).
final class CloudEnv {
  const CloudEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.neonConnectionString,
    required this.firebaseStorageBucket,
    required this.supabaseStorageBucket,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;

  /// Full Postgres connection URI for direct [postgres] clients (dev / tooling).
  final String neonConnectionString;

  /// Default Firebase Storage bucket id (optional).
  final String firebaseStorageBucket;

  /// Default Supabase Storage bucket name.
  final String supabaseStorageBucket;

  factory CloudEnv.fromEnvironment() {
    return const CloudEnv(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
      neonConnectionString: String.fromEnvironment('NEON_CONNECTION_STRING'),
      firebaseStorageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      supabaseStorageBucket: String.fromEnvironment(
        'SUPABASE_STORAGE_BUCKET',
        defaultValue: 'public',
      ),
    );
  }

  bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get hasNeon => neonConnectionString.isNotEmpty;
}

/// Overridden at app bootstrap with [CloudEnv.fromEnvironment()].
final cloudEnvProvider = Provider<CloudEnv>(
  (ref) => throw UnsupportedError(
    'cloudEnvProvider must be overridden via ProviderScope at bootstrap.',
  ),
);
