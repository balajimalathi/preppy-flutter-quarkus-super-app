// This is a generated file - do not edit.
//
// Generated from common/v1/rpc_surface.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = {
  '1': 'PingRequest',
  '2': [
    {'1': 'client', '3': 1, '4': 1, '5': 9, '10': 'client'},
  ],
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode(
    'CgtQaW5nUmVxdWVzdBIWCgZjbGllbnQYASABKAlSBmNsaWVudA==');

@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = {
  '1': 'PingResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode(
    'CgxQaW5nUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use watchJobStatusRequestDescriptor instead')
const WatchJobStatusRequest$json = {
  '1': 'WatchJobStatusRequest',
  '2': [
    {'1': 'job_id', '3': 1, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `WatchJobStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchJobStatusRequestDescriptor = $convert.base64Decode(
    'ChVXYXRjaEpvYlN0YXR1c1JlcXVlc3QSFQoGam9iX2lkGAEgASgJUgVqb2JJZA==');

@$core.Deprecated('Use jobStatusEventDescriptor instead')
const JobStatusEvent$json = {
  '1': 'JobStatusEvent',
  '2': [
    {'1': 'phase', '3': 1, '4': 1, '5': 9, '10': 'phase'},
    {'1': 'detail', '3': 2, '4': 1, '5': 9, '10': 'detail'},
  ],
};

/// Descriptor for `JobStatusEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List jobStatusEventDescriptor = $convert.base64Decode(
    'Cg5Kb2JTdGF0dXNFdmVudBIUCgVwaGFzZRgBIAEoCVIFcGhhc2USFgoGZGV0YWlsGAIgASgJUg'
    'ZkZXRhaWw=');

