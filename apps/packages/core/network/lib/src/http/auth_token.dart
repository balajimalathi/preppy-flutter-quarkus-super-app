import 'package:riverpod/riverpod.dart';

/// Supplies a Firebase ID token (or other bearer) for REST, gRPC metadata,
/// and GraphQL [HttpLink]. Override in [ProviderScope] when auth is wired.
///
/// Default returns null so calls stay anonymous until login exists.
final authTokenProvider = Provider<Future<String?> Function()>(
  (ref) =>
      () async => null,
);
