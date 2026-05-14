/// Backend-agnostic cloud layer with Firebase, Supabase, and Neon adapters.
library;

export 'src/cloud_backend.dart';
export 'src/contracts/cloud_collection.dart';
export 'src/contracts/cloud_database.dart';
export 'src/contracts/cloud_storage.dart';
export 'src/contracts/cloud_transaction.dart';
export 'src/models/cloud_document.dart';
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
export 'src/adapters/supabase/supabase_database.dart' show SupabaseDatabase;
