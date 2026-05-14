/// Backend-agnostic cloud layer with Firebase, Supabase, Neon, and S3-compatible storage.
library;

export 'src/cloud_backend.dart';
export 'src/contracts/cloud_collection.dart';
export 'src/contracts/cloud_database.dart';
export 'src/contracts/cloud_storage.dart';
export 'src/contracts/cloud_transaction.dart';
export 'src/models/cloud_document.dart';
export 'src/models/cloud_download_url_request.dart';
export 'src/models/cloud_filter.dart';
export 'src/models/cloud_query.dart';
export 'src/models/cloud_result.dart';
export 'src/models/cloud_stream_event.dart';
export 'src/models/cloud_upload.dart';
export 'src/providers/cloud_providers.dart';

// Public facades for app bootstrap (collection/tx implementations stay private).
export 'src/adapters/firebase/firebase_storage_adapter.dart'
    show FirebaseStorageAdapter;
export 'src/adapters/firebase/firestore_database.dart' show FirestoreDatabase;
export 'src/adapters/neon/neon_database.dart' show NeonDatabase;
export 'src/adapters/neon/neon_storage_adapter.dart' show NeonStorageAdapter;
export 'src/adapters/s3/s3_public_url.dart' show S3PublicUrl;
export 'src/adapters/s3/s3_storage_adapter.dart'
    show S3CompatibleStorageAdapter;
export 'src/adapters/s3/s3_storage_config.dart';
export 'src/adapters/supabase/supabase_database.dart' show SupabaseDatabase;
export 'src/adapters/supabase/supabase_storage_adapter.dart'
    show SupabaseStorageAdapter;
