# Compile-time environment defines

These JSON files are consumed by Flutter as `--dart-define-from-file=...` at build time. Keys map to `String.fromEnvironment` in the `core_env` package (`AppEnv.fromEnvironment()` only).

- **Tracked defaults:** `env.dev.json`, `env.staging.json`, `env.prod.json` — replace placeholders with your real URLs and keys.
- **Templates:** `env.*.example.json` — reference copies; use untracked `env.*.local.json` for machine-specific values if you prefer not to edit tracked files (point Melos at the local file for local runs).
- **Local API (Android emulator):** copy `env.dev.local.example.json` to `env.dev.local.json` (gitignored). `melos run run:dev` uses it (`BASE_URL` defaults to `http://10.0.2.2:8080` for Quarkus on the host). Use your machine LAN IP for a physical device, or `http://localhost:8080` on the iOS simulator.

Do not commit production secrets if your policy forbids it; use CI-injected defines or local-only JSON instead.
