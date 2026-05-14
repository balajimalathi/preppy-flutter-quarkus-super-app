# preppy_app

Flutter **shell** for the Preppy monorepo: it composes feature packages (`auth`, `dashboard`, `ingestion`, `practice`, `pyq`, `syllabus`), applies `shared_ui` theming, wires **GoRouter**, and bootstraps **Firebase**, **Hive**, **SharedPreferences**, and **Riverpod** overrides for `core_env` / `core_network`.

## Prerequisites

- Flutter SDK matching `pubspec.yaml` (`^3.11.5`).
- [Melos](https://pub.dev/packages/melos) for workspace commands (from repo root).

From the **repository root**:

```bash
dart pub global activate melos
melos bootstrap
```

## Run with a flavor and env file

Always pass **`--dart-define-from-file`** so `AppEnv.fromEnvironment()` receives `BASE_URL` and related keys. From the repo root:

| Command | Flavor | Env file |
|---------|--------|----------|
| `melos run run:dev` | `dev` | `apps/preppy_app/config/env.dev.json` |
| `melos run run:staging` | `staging` | `apps/preppy_app/config/env.staging.json` |
| `melos run run:prod` | `prod` | `apps/preppy_app/config/env.prod.json` |

Equivalent shape:

```bash
cd apps/preppy_app
flutter run --flavor dev --dart-define-from-file=config/env.dev.json -t lib/main_dev.dart
```

Copy `config/env.*.example.json` to the matching `env.*.json` (or use a local untracked JSON) and fill in URLs and project ids. See `config/README.md`.

## Project layout (high level)

| Path | Role |
|------|------|
| `lib/bootstrap/bootstrap.dart` | Firebase, storage init, `ProviderScope` overrides |
| `lib/bootstrap/router.dart` | `GoRouter` built from feature route lists |
| `lib/app.dart` | `MaterialApp.router`, theme, connectivity snackbars (`core_di`) |
| `lib/env/app_env_firebase.dart` | Picks generated `FirebaseOptions` per `Environment` |
| `config/*.json` | Compile-time defines for `--dart-define-from-file` |

## Documentation

Extended guides for flavors, bootstrap, env, and core packages live in the repo **`docs/`** Starlight site (`docs/README.md` for how to run the doc dev server).
