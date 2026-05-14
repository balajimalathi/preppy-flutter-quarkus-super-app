# core_cloud

Backend-agnostic contracts (`CloudCollection`, `CloudDatabase`, `CloudStorage`, `CloudTransaction`) with **Firebase**, **Supabase**, and **Neon** adapters in a **single package**. Feature code depends on the contracts; the app overrides **named** Riverpod providers (`firebaseDatabaseProvider`, `supabaseDatabaseProvider`, `neonDatabaseProvider`, and matching storage providers) so multiple backends can be live at once.

Compile-time keys for optional backends live in **`core_env`** as `CloudEnv` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `NEON_CONNECTION_STRING`, `FIREBASE_STORAGE_BUCKET`, `SUPABASE_STORAGE_BUCKET`).

## Backend capabilities and limits

| Capability | Firestore | Supabase (PostgREST + Realtime) | Neon (Postgres) |
|------------|-----------|----------------------------------|-----------------|
| **Queries** | Mapped to `Query`; composite filters may need **indexes** | PostgREST filters; `WhereContains` uses `ilike` | `WhereEqual` only for server-side filter (`data @> …`); **orderBy** limited to `id` / `data` |
| **watch()** | Native snapshots | Realtime stream; **only one** server-side filter on `.stream()` (first filter wins) | **Polling** (`pollInterval`) — no native push |
| **watchEvents()** | Diff between snapshot lists | Same diff heuristic over polled/stream snapshots | Same heuristic over poll results |
| **Transactions** | Native `runTransaction` | **Buffered client writes** inside `transaction()` — **not** ACID; use **RPC/SQL** for atomicity | Real `runTx` via `postgres`; `NeonTransaction.set/update/delete` queue until `flush()` |
| **Storage** | Firebase Storage | Supabase Storage (bucket from `SupabaseDatabase`) | **Stub** — returns `CloudErrorCode.unsupported`; use S3/R2 or another adapter |

## Neon schema expectation

Tables must expose at least:

- `id TEXT PRIMARY KEY`
- `data JSONB NOT NULL`

`ON CONFLICT (id)` is used for upserts. Add indexes for common `data @>` containment queries as needed.

## Mobile vs Neon

Holding a long-lived Postgres connection string in a mobile client is risky (rotation, abuse, connection limits). Prefer **APIs or Edge functions** for production apps; direct `postgres` is best for **dev**, **desktop**, or **internal tools**.

## Public exports

[`lib/core_cloud.dart`](lib/core_cloud.dart) exports contracts, models, providers, and **only** the façade types `FirestoreDatabase`, `SupabaseDatabase`, `NeonDatabase`, `FirebaseStorageAdapter`, `NeonStorageAdapter`. Internal collection/transaction classes stay in `src/adapters/`.
