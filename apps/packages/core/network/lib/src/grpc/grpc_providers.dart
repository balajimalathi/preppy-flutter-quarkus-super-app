import 'dart:async';

import 'package:core_env/core_env.dart';
import 'package:grpc/grpc.dart';
import 'package:riverpod/riverpod.dart';

import '../http/auth_token.dart';
import '../generated/common/v1/rpc_surface.pbgrpc.dart';

export '../generated/common/v1/rpc_surface.pbgrpc.dart';

/// Shared channel for unary and streaming RPCs. Shuts down on dispose.
final grpcChannelProvider = Provider<ClientChannel>((ref) {
  final env = ref.watch(appEnvProvider);
  final channel = ClientChannel(
    env.effectiveGrpcHost,
    port: env.grpcPort,
    options: ChannelOptions(
      credentials: env.grpcUseTls
          ? const ChannelCredentials.secure()
          : const ChannelCredentials.insecure(),
    ),
  );
  ref.onDispose(() {
    unawaited(channel.shutdown());
  });
  return channel;
});

/// Generated [RpcSurfaceClient] bound to [grpcChannelProvider].
final rpcSurfaceClientProvider = Provider<RpcSurfaceClient>((ref) {
  final channel = ref.watch(grpcChannelProvider);
  return RpcSurfaceClient(channel);
});

/// Per-RPC metadata with bearer token from [authTokenProvider].
Future<CallOptions> grpcCallOptions(Ref ref) async {
  final token = await ref.read(authTokenProvider)();
  if (token == null || token.isEmpty) {
    return CallOptions();
  }
  return CallOptions(metadata: {'authorization': 'Bearer $token'});
}
