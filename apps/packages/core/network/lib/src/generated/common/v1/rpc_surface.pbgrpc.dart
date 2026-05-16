// This is a generated file - do not edit.
//
// Generated from common/v1/rpc_surface.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'rpc_surface.pb.dart' as $0;

export 'rpc_surface.pb.dart';

@$pb.GrpcServiceName('common.v1.RpcSurface')
class RpcSurfaceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RpcSurfaceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.PingResponse> ping(
    $0.PingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$ping, request, options: options);
  }

  $grpc.ResponseStream<$0.JobStatusEvent> watchJobStatus(
    $0.WatchJobStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchJobStatus, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$ping = $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
      '/common.v1.RpcSurface/Ping',
      ($0.PingRequest value) => value.writeToBuffer(),
      $0.PingResponse.fromBuffer);
  static final _$watchJobStatus =
      $grpc.ClientMethod<$0.WatchJobStatusRequest, $0.JobStatusEvent>(
          '/common.v1.RpcSurface/WatchJobStatus',
          ($0.WatchJobStatusRequest value) => value.writeToBuffer(),
          $0.JobStatusEvent.fromBuffer);
}

@$pb.GrpcServiceName('common.v1.RpcSurface')
abstract class RpcSurfaceServiceBase extends $grpc.Service {
  $core.String get $name => 'common.v1.RpcSurface';

  RpcSurfaceServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WatchJobStatusRequest, $0.JobStatusEvent>(
        'WatchJobStatus',
        watchJobStatus_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.WatchJobStatusRequest.fromBuffer(value),
        ($0.JobStatusEvent value) => value.writeToBuffer()));
  }

  $async.Future<$0.PingResponse> ping_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PingRequest> $request) async {
    return ping($call, await $request);
  }

  $async.Future<$0.PingResponse> ping(
      $grpc.ServiceCall call, $0.PingRequest request);

  $async.Stream<$0.JobStatusEvent> watchJobStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WatchJobStatusRequest> $request) async* {
    yield* watchJobStatus($call, await $request);
  }

  $async.Stream<$0.JobStatusEvent> watchJobStatus(
      $grpc.ServiceCall call, $0.WatchJobStatusRequest request);
}
