import 'package:dio/dio.dart';

final class ProfileFetchException implements Exception {
  ProfileFetchException(
    this.message, {
    this.cause,
    this.statusCode,
  });

  final String message;
  final Object? cause;
  final int? statusCode;

  /// HTTP 401/403 — server rejected the Firebase token or denied access.
  bool get isAuthFailure {
    final code = statusCode;
    return code == 401 || code == 403;
  }

  /// No response from the API (offline, wrong host, timeout).
  bool get isNetworkFailure {
    if (cause is DioException) {
      final type = (cause! as DioException).type;
      return type == DioExceptionType.connectionError ||
          type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.sendTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.unknown;
    }
    return statusCode == null;
  }

  @override
  String toString() => 'ProfileFetchException: $message';
}
