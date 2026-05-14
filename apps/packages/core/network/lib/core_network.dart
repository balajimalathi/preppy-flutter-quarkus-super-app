import 'package:riverpod/riverpod.dart';

import 'src/http/api_client.dart';
import 'src/http/sse_client.dart';

export 'src/graphql/graphql_providers.dart';
export 'src/grpc/grpc_providers.dart';
export 'src/http/api_client.dart'
    show ApiClient, apiClientProvider, baseUrlProvider, dioProvider;
export 'src/http/auth_token.dart' show authTokenProvider;
export 'src/http/multipart_helpers.dart' show singleFileFormData;
export 'src/http/sse_client.dart' show SseClient, SseMessage;

/// SSE helper bound to [dioProvider].
final sseClientProvider = Provider<SseClient>(
  (ref) => SseClient(ref.watch(dioProvider)),
);
