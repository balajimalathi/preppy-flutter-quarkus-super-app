import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

import 'auth_interceptor.dart';
import 'auth_token.dart';

/// HTTP API origin; overridden at app bootstrap (see `core_env` / shell).
final baseUrlProvider = Provider<String>(
  (ref) => throw UnsupportedError(
    'baseUrlProvider must be overridden via ProviderScope at bootstrap.',
  ),
);

/// Thin wrapper that constructs the shared [Dio] instance used by every
/// feature package. Interceptors (auth, retry, logging) get attached here.
class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  Dio build(Ref ref) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(AuthInterceptor(() => ref.read(authTokenProvider)()));
    return dio;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return ApiClient(baseUrl: baseUrl);
});

/// Shared [Dio] with base URL and [AuthInterceptor].
final dioProvider = Provider<Dio>((ref) {
  final api = ref.watch(apiClientProvider);
  final dio = api.build(ref);
  ref.onDispose(dio.close);
  return dio;
});
