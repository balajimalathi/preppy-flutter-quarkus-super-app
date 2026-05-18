import 'package:meta/meta.dart';

/// Sentinel value for successful operations with no payload.
typedef CloudUnit = ();

const CloudUnit cloudUnit = ();

/// Portable error codes mapped from backend-specific failures.
enum CloudErrorCode {
  notFound,
  permissionDenied,
  networkError,
  transactionFailed,
  storageError,
  unsupported,
  unknown,
}

/// Result of a cloud operation.
sealed class CloudResult<T> {
  const CloudResult();

  /// Maps success and error branches into a single value.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, CloudErrorCode code) onError,
  }) {
    final self = this;
    return switch (self) {
      CloudSuccess<T>(:final data) => onSuccess(data),
      CloudError<T>(:final message, :final code) => onError(message, code),
    };
  }
}

@immutable
/// Successful cloud operation containing [data].
final class CloudSuccess<T> extends CloudResult<T> {
  const CloudSuccess(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CloudSuccess<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;
}

@immutable
/// Failed cloud operation containing a user-facing [message] and typed [code].
final class CloudError<T> extends CloudResult<T> {
  const CloudError({required this.message, required this.code});

  final String message;
  final CloudErrorCode code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudError<T> && other.message == message && other.code == code;

  @override
  int get hashCode => Object.hash(message, code);
}
