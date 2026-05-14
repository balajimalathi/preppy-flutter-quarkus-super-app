# core_storage

String key–value storage for Flutter with shared validation, debug logging, and consistent `StorageException` wrapping. Ships Hive, secure storage, and SharedPreferences implementations plus Riverpod providers.

## Usage

Depend on `core_storage` and use [`StorageContract`](lib/src/storage_contract.dart) from the app (for example via [`storage_provider.dart`](lib/src/storage_provider.dart)):

```dart
import 'package:core_storage/core_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> example(WidgetRef ref) async {
  final storage = ref.read(storageProvider);
  await storage.write('theme', 'dark');
  final theme = await storage.read('theme');
  await storage.delete('theme');
  await storage.clear();
}
```

Call `read`, `write`, `delete`, `containsKey`, and `clear` on the contract type only. Empty or whitespace-only keys throw `StorageException` before the backend runs.

Initialize platform pieces before first use where required (see your app `main.dart`): e.g. `SharedPreferencesSingleton.init()`, `Hive.initFlutter()` for Hive-backed storage.

## Custom backends

Subclass [`BaseStorage`](lib/src/base_storage.dart) and implement the `@protected` primitives (`readRaw`, `writeRaw`, `deleteRaw`, `containsKeyRaw`, `clearRaw`). The public `read` / `write` / … methods on the base class perform key validation and error wrapping; do not reimplement that in subclasses.

## Mixins

This package does not ship mixins. Define a `mixin` on `ConsumerState` that reads `storageProvider` / `secureStorageProvider` for shared helpers (see **core_storage** in repo `docs/`).

## Additional information

This package is not published (`publish_to: 'none'`). Run tests from the package root:

```bash
flutter test
```
