import 'package:core_models/core_models.dart';

/// Loads data via [call] and maps [Result] failures to [AppError] in [execute].
abstract class ResultUseCase<T> {
  Future<Result<T>> call();

  Future<T> execute() async {
    final result = await call();
    return switch (result) {
      Success(:final data) => data,
      FailureResult(:final failure) => throw failure.toAppError(),
    };
  }
}
