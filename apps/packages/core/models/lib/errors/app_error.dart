import '../network/failure.dart';

/// Typed errors for use cases and presentation. Map from [Failure] at the
/// use-case boundary; ViewModels must not use raw strings.
sealed class AppError {
  const AppError();
}

/// Network or remote API failure with an optional HTTP-style [statusCode].
final class NetworkError extends AppError {
  const NetworkError({this.statusCode, required this.message});

  final int? statusCode;
  final String message;
}

/// The requested resource does not exist.
final class NotFoundError extends AppError {
  const NotFoundError(this.resource);

  final String resource;
}

/// Authentication or authorization is required before retrying.
final class UnauthorizedError extends AppError {
  const UnauthorizedError();
}

/// The request payload was rejected for one or more fields.
final class ValidationError extends AppError {
  const ValidationError(this.fieldErrors);

  final Map<String, String> fieldErrors;
}

/// Fallback error for unexpected failures that do not fit a domain-specific type.
final class UnknownError extends AppError {
  const UnknownError(this.cause);

  final Object cause;
}

/// Converts repository/data-source [Failure] values into UI-facing [AppError]s.
extension FailureToAppError on Failure {
  AppError toAppError() {
    return switch (this) {
      NetworkFailure() => NetworkError(statusCode: code, message: message),
      CacheFailure() => NetworkError(statusCode: code, message: message),
      UnknownFailure() => UnknownError(cause ?? message),
    };
  }
}

/// Maps HTTP-style status codes to [AppError] when adapting API layers.
AppError appErrorFromStatusCode({
  required int? statusCode,
  required String message,
  String notFoundResource = 'Resource',
}) {
  return switch (statusCode) {
    401 => const UnauthorizedError(),
    404 => NotFoundError(notFoundResource),
    503 => NetworkError(statusCode: 503, message: message),
    _ => NetworkError(statusCode: statusCode, message: message),
  };
}
