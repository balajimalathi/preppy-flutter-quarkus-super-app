/// Progressive async state for API-driven UI.
///
/// **Hybrid pattern (recommended):** keep terminal outcomes as
/// `Future<Either<Failure, T>>` (or similar) inside your data/repository layer,
/// then adapt to `Stream<ApiResult<T>>` in a use case: emit [ApiResult.loading],
/// `await` the future, and `yield` [ApiResult.success] or [ApiResult.error]
/// from the [Either] fold. That gives you exhaustive [switch] on UI state
/// without overloading [Either] with loading/idle.
library;

/// Sealed union: idle → loading → success | error.
///
/// Generic [T] is the success payload type. Error carries a message plus
/// optional HTTP or domain code and original cause for logging.
sealed class ApiResult<T> {
  const ApiResult._();

  const factory ApiResult.idle() = ApiIdle<T>;

  const factory ApiResult.loading({T? previousData}) = ApiLoading<T>;

  const factory ApiResult.success(T data) = ApiSuccess<T>;

  const factory ApiResult.error({
    required String message,
    int? code,
    Object? cause,
  }) = ApiError<T>;

  /// Whether this is a terminal outcome ([ApiSuccess] or [ApiError]).
  bool get isTerminal => switch (this) {
    ApiSuccess<T>() || ApiError<T>() => true,
    _ => false,
  };

  /// Latest successful or stale data, if any.
  T? get dataOrNull => switch (this) {
    ApiSuccess(:final data) => data,
    ApiLoading(:final previousData) => previousData,
    _ => null,
  };

  /// Exhaustive callback-style dispatch.
  R when<R>({
    required R Function() idle,
    required R Function(T? previousData) loading,
    required R Function(T data) success,
    required R Function(String message, int? code, Object? cause) error,
  }) {
    return switch (this) {
      ApiIdle<T>() => idle(),
      ApiLoading(:final previousData) => loading(previousData),
      ApiSuccess(:final data) => success(data),
      ApiError(:final message, :final code, :final cause) => error(
        message,
        code,
        cause,
      ),
    };
  }

  /// Terminal states only; [idle] and [loading] map to [orElse].
  R foldTerminal<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, int? code, Object? cause) onError,
    required R Function() orElse,
  }) {
    return switch (this) {
      ApiSuccess(:final data) => onSuccess(data),
      ApiError(:final message, :final code, :final cause) => onError(
        message,
        code,
        cause,
      ),
      _ => orElse(),
    };
  }
}

/// Idle state before any API work has started.
final class ApiIdle<T> extends ApiResult<T> {
  const ApiIdle() : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ApiIdle<T>;

  @override
  int get hashCode => (ApiIdle).hashCode;
}

/// Loading state that may optionally retain stale [previousData].
final class ApiLoading<T> extends ApiResult<T> {
  const ApiLoading({this.previousData}) : super._();

  final T? previousData;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiLoading<T> && other.previousData == previousData);
  }

  @override
  int get hashCode => Object.hash(ApiLoading, previousData);
}

/// Successful API state containing [data].
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data) : super._();

  final T data;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiSuccess<T> && other.data == data);
  }

  @override
  int get hashCode => Object.hash(ApiSuccess, data);
}

/// Failed API state containing a user-facing [message] and optional metadata.
final class ApiError<T> extends ApiResult<T> {
  const ApiError({required this.message, this.code, this.cause}) : super._();

  final String message;
  final int? code;
  final Object? cause;

  /// Maps a thrown value to [ApiError] (e.g. in a `catch` before yielding).
  factory ApiError.fromException(
    Object exception, {
    int? code,
    StackTrace? stackTrace,
  }) {
    return ApiError<T>(
      message: exception.toString(),
      code: code,
      cause: stackTrace ?? exception,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiError<T> &&
            other.message == message &&
            other.code == code &&
            other.cause == cause);
  }

  @override
  int get hashCode => Object.hash(ApiError, message, code, cause);
}

/// Convenience boolean helpers for narrowing [ApiResult] variants.
extension ApiResultStatus<T> on ApiResult<T> {
  bool get isIdle => this is ApiIdle<T>;

  bool get isLoading => this is ApiLoading<T>;

  bool get isSuccess => this is ApiSuccess<T>;

  bool get isError => this is ApiError<T>;
}
