import 'package:riverpod/riverpod.dart';

import '../contracts/cloud_database.dart';
import '../contracts/cloud_storage.dart';

/// Primary Firestore-backed database — override in [ProviderScope] at bootstrap.
final firebaseDatabaseProvider = Provider<CloudDatabase>(
  (ref) => throw UnsupportedError(
    'Override firebaseDatabaseProvider in ProviderScope (e.g. FirestoreDatabase()).',
  ),
);

/// Supabase PostgREST + Realtime + Storage — requires [Supabase.initialize] first.
final supabaseDatabaseProvider = Provider<CloudDatabase>(
  (ref) => throw UnsupportedError(
    'Override supabaseDatabaseProvider in ProviderScope (e.g. SupabaseDatabase(client)).',
  ),
);

/// Direct Postgres (Neon) — prefer server-mediated access for production mobile.
final neonDatabaseProvider = Provider<CloudDatabase>(
  (ref) => throw UnsupportedError(
    'Override neonDatabaseProvider in ProviderScope (e.g. NeonDatabase(connection:)).',
  ),
);

/// Firebase Storage — override at bootstrap (e.g. [FirebaseStorageAdapter]).
final firebaseStorageProvider = Provider<CloudStorage>(
  (ref) => throw UnsupportedError(
    'Override firebaseStorageProvider in ProviderScope.',
  ),
);

/// Supabase Storage — override at bootstrap.
final supabaseStorageProvider = Provider<CloudStorage>(
  (ref) => throw UnsupportedError(
    'Override supabaseStorageProvider in ProviderScope.',
  ),
);

/// S3-compatible storage (R2, MinIO, RustFS, AWS S3) — override at bootstrap
/// with `S3CompatibleStorageAdapter` and `S3StorageConfig`.
final s3StorageProvider = Provider<CloudStorage>(
  (ref) => throw UnsupportedError(
    'Override s3StorageProvider in ProviderScope.',
  ),
);

/// Neon / external object storage placeholder.
final neonStorageProvider = Provider<CloudStorage>(
  (ref) =>
      throw UnsupportedError('Override neonStorageProvider in ProviderScope.'),
);
