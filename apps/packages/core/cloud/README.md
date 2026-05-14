# core_cloud

Backend-agnostic contracts (`CloudCollection`, `CloudDatabase`, `CloudStorage`, `CloudTransaction`) with **Firebase**, **Supabase**, **Neon**, and **S3-compatible** storage in one package. Feature code should depend on the **contracts** and **named Riverpod providers**; the **app shell** wires concrete adapters at bootstrap by overriding those providers on `ProviderScope`.

Compile-time keys for optional backends live in **`core_env`** as `CloudEnv` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `NEON_CONNECTION_STRING`, `FIREBASE_STORAGE_BUCKET`, `SUPABASE_STORAGE_BUCKET`).

---

## Add the package

In your app (or a feature package) `pubspec.yaml`:

```yaml
dependencies:
  core_cloud:
    path: ../packages/core/cloud  # from apps/preppy_app
    # path: ../cloud              # from another apps/packages/core/* package
```

Most apps already pull cloud types through **`core_di`**, which re-exports `package:core_cloud/core_cloud.dart`. Prefer one import at the feature boundary:

```dart
import 'package:core_di/core_di.dart';
// or, if this package depends on core_cloud directly:
import 'package:core_cloud/core_cloud.dart';
```

The public entrypoint is [`lib/core_cloud.dart`](lib/core_cloud.dart): contracts, models (including `CloudDownloadUrlRequest`), providers, and façade adapters (`FirestoreDatabase`, `SupabaseDatabase`, `NeonDatabase`, `FirebaseStorageAdapter`, `SupabaseStorageAdapter`, `NeonStorageAdapter`, `S3CompatibleStorageAdapter`, `S3StorageConfig`, `S3PublicUrl`). Low-level collection/transaction implementations stay under `lib/src/adapters/`.

---

## Bootstrap: `ProviderScope` overrides

`core_cloud` providers are **declared** with `throw UnsupportedError(...)` until you **override** them. Do that once, as high in the widget tree as practical (same place you override `appEnvProvider`, `cloudEnvProvider`, etc.).

### Minimal pattern

1. Perform any required SDK init **before** `runApp` (e.g. `Firebase.initializeApp`, `Supabase.initialize`).
2. Wrap your root widget in `ProviderScope(overrides: [...], child: ...)`.
3. For each backend you use, override the matching `*DatabaseProvider` and/or `*StorageProvider` with a **long-lived** instance (typically `Provider` overrides with `.overrideWithValue(...)`).

Example shape (your constructors and env flags will differ):

```dart
import 'package:core_cloud/core_cloud.dart';
import 'package:core_env/core_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(/* options */);
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final cloudEnv = CloudEnv.fromEnvironment();
  final supabaseClient = Supabase.instance.client;

  runApp(
    ProviderScope(
      overrides: [
        cloudEnvProvider.overrideWithValue(cloudEnv),

        // Databases (override only what you use)
        firebaseDatabaseProvider.overrideWithValue(FirestoreDatabase()),
        supabaseDatabaseProvider.overrideWithValue(
          SupabaseDatabase(client: supabaseClient),
        ),

        // Storage (override only what you use)
        firebaseStorageProvider.overrideWithValue(FirebaseStorageAdapter()),
        supabaseStorageProvider.overrideWithValue(
          SupabaseStorageAdapter(client: supabaseClient, bucket: 'avatars'),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Provider cheat sheet

| Provider | Typical implementation | When to set it |
|----------|-------------------------|----------------|
| `firebaseDatabaseProvider` | `FirestoreDatabase()` | You use Firestore as `CloudDatabase`. |
| `supabaseDatabaseProvider` | `SupabaseDatabase(client: …)` | After `Supabase.initialize`. |
| `neonDatabaseProvider` | `NeonDatabase(connection: …)` | Dev/tools or trusted clients; see Neon section below. |
| `firebaseStorageProvider` | `FirebaseStorageAdapter()` | Firebase Storage. |
| `supabaseStorageProvider` | `SupabaseStorageAdapter(client: …, bucket: …)` | Supabase Storage. |
| `s3StorageProvider` | `S3CompatibleStorageAdapter(config: S3StorageConfig(...))` | R2, MinIO, RustFS, AWS S3, etc. |
| `neonStorageProvider` | `NeonStorageAdapter()` (stub) or another `CloudStorage` | Placeholder unless you point Neon apps at S3/Supabase/Firebase storage. |

You can override **several** database or storage providers at once if different features use different backends; consumers choose which `Provider<CloudStorage>` (or database) they read.

### S3-compatible storage at bootstrap

Use **constructor-injected** credentials (from secure storage, `--dart-define`, or a config object loaded at startup). Avoid hard-coding secrets in source.

```dart
s3StorageProvider.overrideWithValue(
  S3CompatibleStorageAdapter(
    config: S3StorageConfig(
      endpoint: 's3.us-east-1.amazonaws.com', // or R2 / MinIO host
      accessKey: accessKey,
      secretKey: secretKey,
      sessionToken: sessionToken, // optional STS
      region: 'us-east-1', // or `auto` for R2
      bucket: 'my-bucket',
      useSSL: true,
      port: null,
      enablePathStyle: true, // often required for MinIO / self-hosted
      publicBaseUrl: null, // optional CDN or public origin for `CloudUrlKind.public`
      defaultSignedExpiry: Duration(hours: 1),
      uploadResultUrlKind: CloudUrlKind.signed,
    ),
  ),
),
```

This package signs requests with **AWS Signature Version 4** (`aws_signature_v4`); it does not ship the `minio` client (workspace resolution conflicts with `flutterfire_cli` in this repo).

---

## Inside the app: reading providers and calling APIs

### Riverpod

Inject `WidgetRef` or `Ref` and read the same provider you overrode at bootstrap:

```dart
final storage = ref.watch(firebaseStorageProvider);
// or
final storage = ref.read(s3StorageProvider);
```

Use `read` for one-off calls (upload on button press); use `watch` if the UI should rebuild when you replace the implementation (rare for static overrides).

### `CloudResult`

All operations return `CloudResult<T>` (`CloudSuccess` / `CloudError`). Use `fold` or pattern matching:

```dart
final result = await ref.read(s3StorageProvider).upload(config);
switch (result) {
  case CloudSuccess(:final data):
    useUrl(data.url);
  case CloudError(:final message, :final code):
    showError(message);
}
```

### `CloudStorage`: uploads and URLs

- `upload(CloudUploadConfig)` — bytes, path, MIME type, optional metadata.
- `getDownloadUrl(path, request: …)` — optional [`CloudDownloadUrlRequest`](lib/src/models/cloud_download_url_request.dart) chooses **legacy** (per-adapter default), **public**, or **time-limited signed** URLs where supported.
- `deleteFile(path)` — remove object.
- `uploadProgress(config)` — `0.0`–`1.0` stream; granularity depends on the adapter (Firebase: fine-grained; others may jump to `1.0`).

Example (Supabase / S3-style signed vs public):

```dart
final url = await storage.getDownloadUrl(
  'users/123/avatar.png',
  request: CloudDownloadUrlRequest(
    kind: CloudUrlKind.signed,
    expiresIn: Duration(minutes: 15),
  ),
);
```

Firebase’s `getDownloadURL` is still a **tokenized** URL; `CloudUrlKind.public` / `signed` do not change the Firebase SDK behavior—see adapter docs in source.

### `CloudDatabase` / `CloudCollection`

Obtain a collection from your `CloudDatabase` façade (e.g. `SupabaseDatabase.collection('posts')`), then `query`, `get`, `watch`, `upsert`, etc., per [`CloudCollection`](lib/src/contracts/cloud_collection.dart). Prefer keeping collection paths and query construction in repositories, not widgets.

---

## Mixins

`core_cloud` does not ship mixins. Use an app-side mixin on `ConsumerState` for `ref.read(firebaseDatabaseProvider)` (or the storage provider you override). See **core_cloud** in repo `docs/`.

## This repo’s app shell (`preppy_app`)

`apps/preppy_app/lib/bootstrap/bootstrap.dart` currently overrides `appEnvProvider`, `cloudEnvProvider`, and `baseUrlProvider` only. When you start using `core_cloud` in the app, add the same `ProviderScope` `overrides:` entries for the database/storage providers you need, after the relevant SDK initialization in that file (or a dedicated `cloud_bootstrap.dart` imported from there).

---

## Backend capabilities and limits

| Capability | Firestore | Supabase (PostgREST + Realtime) | Neon (Postgres) |
|------------|-----------|----------------------------------|-----------------|
| **Queries** | Mapped to `Query`; composite filters may need **indexes** | PostgREST filters; `WhereContains` uses `ilike` | `WhereEqual` only for server-side filter (`data @> …`); **orderBy** limited to `id` / `data` |
| **watch()** | Native snapshots | Realtime stream; **only one** server-side filter on `.stream()` (first filter wins) | **Polling** (`pollInterval`) — no native push |
| **watchEvents()** | Diff between snapshot lists | Same diff heuristic over polled/stream snapshots | Same heuristic over poll results |
| **Transactions** | Native `runTransaction` | **Buffered client writes** inside `transaction()` — **not** ACID; use **RPC/SQL** for atomicity | Real `runTx` via `postgres`; `NeonTransaction.set/update/delete` queue until `flush()` |
| **Storage** | Firebase Storage | Supabase Storage (bucket from adapter config) | **Stub** — use `S3CompatibleStorageAdapter`, Supabase, or Firebase storage |

## Neon schema expectation

Tables must expose at least:

- `id TEXT PRIMARY KEY`
- `data JSONB NOT NULL`

`ON CONFLICT (id)` is used for upserts. Add indexes for common `data @>` containment queries as needed.

## Mobile vs Neon

Holding a long-lived Postgres connection string in a mobile client is risky (rotation, abuse, connection limits). Prefer **APIs or Edge functions** for production apps; direct `postgres` is best for **dev**, **desktop**, or **internal tools**.

## S3 credentials and production

Long-lived access keys inside a shipped mobile app are easy to extract. Prefer **short-lived credentials** from your backend, **presigned PUT/GET** flows, or a **BFF** that performs uploads on behalf of the client.
