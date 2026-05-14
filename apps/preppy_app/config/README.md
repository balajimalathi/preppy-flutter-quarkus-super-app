# Compile-time environment defines

These JSON files are consumed by Flutter as `--dart-define-from-file=...` at build time. Keys map to `String.fromEnvironment` in the `core_env` package (`AppEnv.fromEnvironment()` only).

- **Tracked defaults:** `env.dev.json`, `env.staging.json`, `env.prod.json` — replace placeholders with your real URLs and keys.
- **Templates:** `env.*.example.json` — reference copies; use untracked `env.*.local.json` for machine-specific values if you prefer not to edit tracked files (point Melos at the local file for local runs).

Do not commit production secrets if your policy forbids it; use CI-injected defines or local-only JSON instead.
