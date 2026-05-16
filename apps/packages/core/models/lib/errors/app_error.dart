import '../network/failure.dart';

/// Typed errors for use cases and presentation. Map from [Failure] at the
/// use-case boundary; ViewModels must not use raw strings.
sealed class AppError {
  const AppError();
}

final class NetworkError extends AppError {
  const NetworkError({this.statusCode, required this.message});

  final int? statusCode;
  final String message;
}

final class NotFoundError extends AppError {
  const NotFoundError(this.resource);

  final String resource;
}

final class UnauthorizedError extends AppError {
  const UnauthorizedError();
}

final class ValidationError extends AppError {
  const ValidationError(this.fieldErrors);

  final Map<String, String> fieldErrors;
}

final class UnknownError extends AppError {
  const UnknownError(this.cause);

  final Object cause;
}

extension FailureToAppError on Failure {
  AppError toAppError() {
    return switch (this) {
      NetworkFailure() => NetworkError(
        statusCode: code,
        message: message,
      ),
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
