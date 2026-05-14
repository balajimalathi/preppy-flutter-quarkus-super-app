# core_network

Shared networking: HTTP (`Dio`), SSE, GraphQL (`graphql` + `HttpLink`), gRPC (`grpc` + generated stubs), and connectivity.

## Imports

- **`package:core_network/core_network.dart`** — REST (`dioProvider`, `apiClientProvider`, `authTokenProvider`, `sseClientProvider`), GraphQL (`graphQLClientProvider`, `fetchDashboardHeartbeat`), gRPC (`grpcChannelProvider`, `rpcSurfaceClientProvider`, `grpcCallOptions`), and multipart helpers.
- **`package:core_network/core_connectivity.dart`** — `ConnectivityContract`, `ConnectivityState`, `connectivityServiceProvider`, and `connectivityStateProvider` (Riverpod). Use this entrypoint when you only need reachability and want a smaller import graph.

For a single import of all shared providers, use **`package:core_di/core_di.dart`**.

## gRPC codegen

Proto: [`proto/common/v1/rpc_surface.proto`](proto/common/v1/rpc_surface.proto). From this package directory:

```bash
dart pub global activate protoc_plugin
export PATH="$PATH:$HOME/.pub-cache/bin"
mkdir -p lib/src/generated/common/v1
protoc --dart_out=grpc:lib/src/generated -I proto proto/common/v1/rpc_surface.proto
```

## Connectivity

`ConnectivityMonitor` wraps `connectivity_plus` with debouncing and consecutive-state deduplication. Plugin types are not part of the public API.
