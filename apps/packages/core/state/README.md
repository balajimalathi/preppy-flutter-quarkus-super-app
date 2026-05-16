# core_di

A **single import** barrel that re-exports shared Riverpod surfaces from analytics, auth, cloud, env, and network (including connectivity).

## Re-exports

From `lib/core_di.dart`:

- `package:core_analytics/core_analytics.dart`
- `package:core_auth/core_auth.dart`
- `package:core_cloud/core_cloud.dart`
- `package:core_env/core_env.dart`
- `package:core_network/core_network.dart`
- `package:core_network/core_connectivity.dart` — `ConnectivityContract`, `ConnectivityNotifier`, `ConnectivityState`, `connectivityServiceProvider`, `connectivityStateProvider`

**Not re-exported:** `core_storage`. Import `package:core_storage/core_storage.dart` when you need storage providers.

## Dependency graph

`core_di` depends on the packages above (see `pubspec.yaml`). It does not add new providers; it only aggregates exports for ergonomics.

## Add the package

```yaml
dependencies:
  core_di:
    path: ../di
```

## When to use this vs direct imports

- Prefer **`core_di`** in the shell or features that already touch several cross-cutting areas (e.g. connectivity + env types).
- Prefer a **direct** `core_*` dependency when a package should stay minimal (e.g. only `core_network` for an HTTP-only client).

## Usage

```dart
import 'package:core_di/core_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void listenOnline(WidgetRef ref) {
  ref.listen(connectivityStateProvider, (prev, next) {});
}
```

## Mixins

`core_di` is a barrel only — no mixins. Combine multiple `ref.read` accessors in your own mixin (see **core_di** in repo `docs/`); add `package:dio/dio.dart` if you expose `dioProvider` as `Dio`.

## Documentation

Starlight: **core_di** in the repo `docs/` site.
