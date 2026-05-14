# core_models

**Pure Dart** shared domain types so feature packages agree on JSON-shaped entities without pulling in Flutter.

## Exports

See `lib/core_models.dart` — includes:

- **`ApiResult<T>`** — Sealed union for idle / loading / success / error UI flows (`lib/network/api_result.dart`).
- **Entities** — `Question`, `Flashcard`, `DailyPlan`, `SyllabusItem`, etc.

## Add the package

```yaml
dependencies:
  core_models:
    path: ../models
```

## Usage

```dart
import 'package:core_models/core_models.dart';

void example() {
  const result = ApiResult<Question>.loading();
  // Parse JSON in repositories; map failures to ApiResult.error.
}
```

Keep parsing and DTOs here; keep widgets and `BuildContext` in feature packages.

## Mixins

Pure Dart: no Riverpod here. You can use a `mixin` for JSON → entity mapping shared across repositories (example on **core_models** in repo `docs/`).

## Documentation

Starlight: **core_models** in the repo `docs/` site.
