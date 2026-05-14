import 'package:dio/dio.dart';

/// Attaches `Authorization: Bearer <token>` when [getToken] returns non-empty.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._getToken);

  final Future<String?> Function() _getToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
