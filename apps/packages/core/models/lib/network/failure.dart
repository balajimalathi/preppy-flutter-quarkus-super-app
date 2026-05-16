/// Domain-level failure for repository and data-source layers.
sealed class Failure {
  const Failure({required this.message, this.code, this.cause});

  final String message;
  final int? code;
  final Object? cause;
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.cause});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code, super.cause});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code, super.cause});
}
