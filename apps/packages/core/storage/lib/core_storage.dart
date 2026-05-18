/// Storage package entrypoint.
///
/// Exposes the storage contract, default provider wiring, and shared
/// preferences bootstrap used by the package's storage backends.
library;

export 'src/shared_preferences_singleton.dart';
export 'src/storage_contract.dart';
export 'src/storage_provider.dart';
