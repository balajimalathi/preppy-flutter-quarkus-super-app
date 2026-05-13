# core_network

Shared HTTP (`Dio`) and connectivity for Preppy apps.

## Imports

- **`package:core_network/core_network.dart`** — `ApiClient` / `apiClientProvider` only. Use this when you do not need reachability; it avoids pulling the connectivity plugin into your compilation unit.
- **`package:core_network/core_connectivity.dart`** — `ConnectivityContract`, `ConnectivityState`, `connectivityServiceProvider`, and `connectivityStateProvider` (Riverpod). The slice provider exposes `AsyncValue<ConnectivityState>` when watched.

For a single import of all shared providers, use **`package:core_di/core_di.dart`**.

## Connectivity

`ConnectivityMonitor` wraps `connectivity_plus` with debouncing and consecutive-state deduplication. Plugin types are not part of the public API.
