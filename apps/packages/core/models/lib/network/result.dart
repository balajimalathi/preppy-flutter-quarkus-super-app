import 'api_result.dart';
import 'failure.dart';

/// Terminal outcome for repository / data-source layers.
///
/// Map to [ApiResult] in use cases for progressive UI state (loading/idle).
sealed class Result<T> {
  const Result._();

  const factory Result.success(T data) = Success<T>;

  const factory Result.failure(Failure failure) = FailureResult<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      FailureResult(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data) : super._();

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.data == data);

  @override
  int get hashCode => Object.hash(Success, data);
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure) : super._();

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FailureResult<T> && other.failure == failure);

  @override
  int get hashCode => Object.hash(FailureResult, failure);
}

extension ResultToApiResult<T> on Result<T> {
  /// Maps a terminal [Result] to [ApiResult.success] or [ApiResult.error].
  ApiResult<T> toApiResult() {
    return switch (this) {
      Success(:final data) => ApiResult.success(data),
      FailureResult(:final failure) => ApiResult.error(
        message: failure.message,
        code: failure.code,
        cause: failure.cause,
      ),
    };
  }
}
