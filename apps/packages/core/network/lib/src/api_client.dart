import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

/// Thin wrapper that constructs the shared [Dio] instance used by every
/// feature package. Interceptors (auth, retry, logging) get attached here.
class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  Dio build() {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    // TODO: attach AuthInterceptor that refreshes Firebase ID tokens.
    return dio;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'https://preppy.skndan.com');
});
