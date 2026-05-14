# core_env

Typed **compile-time** configuration from `String.fromEnvironment` / `--dart-define-from-file`, plus Riverpod hooks so the rest of the app reads config through providers.

## Contents

- **`AppEnv`** — `Environment` (`dev` / `staging` / `prod`), `BASE_URL`, Firebase project id, analytics and Crashlytics flags, gRPC and GraphQL settings. Built with `AppEnv.fromEnvironment()`.
- **`CloudEnv`** — Optional Supabase, Neon, and storage bucket defines. Built with `CloudEnv.fromEnvironment()`.
- **`appEnvProvider`** / **`cloudEnvProvider`** — Throw until overridden in `ProviderScope` at app startup.

## Add the package

```yaml
dependencies:
  core_env:
    path: ../env  # adjust for your package location
```

## Usage

```dart
import 'package:core_env/core_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void example(WidgetRef ref) {
  final env = ref.read(appEnvProvider);
  final rest = env.restBaseUri;
  final graphql = env.graphqlHttpUrl;
}
```

The shell **must** override `appEnvProvider` and typically `cloudEnvProvider` when the app starts (see `apps/preppy_app/lib/bootstrap/bootstrap.dart`).

## Define files

The Preppy shell keeps JSON under `apps/preppy_app/config/` and runs Flutter with `--dart-define-from-file=...`. Keys must match the `String.fromEnvironment` names in `lib/src/app_env.dart` and `lib/src/cloud_env.dart`. See `apps/preppy_app/config/README.md` for file layout.

## Mixins

This package does **not** declare mixins. In your app you can add a small mixin on `ConsumerState` that reads `appEnvProvider` / `cloudEnvProvider` once (see the **core_env** page under repo `docs/`).

## Documentation

Starlight topics: **Environment setup** and **core_env** in the repo `docs/` site.
