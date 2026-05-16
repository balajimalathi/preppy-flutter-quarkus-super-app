import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';

/// Maps typed [AppError] to user-facing copy. Features must not build strings
/// from errors in widgets.
String resolveErrorMessage(AppError error) => switch (error) {
  NetworkError(:final statusCode, :final message) =>
    statusCode == 503 ? 'Service unavailable. Try again later.' : message,
  UnauthorizedError() => 'Session expired. Please log in again.',
  NotFoundError(:final resource) => '$resource could not be found.',
  ValidationError(:final fieldErrors) => fieldErrors.values.first,
  UnknownError() => 'Something went wrong. Please try again.',
};

/// Centered error message with optional retry.
class ErrorBody extends StatelessWidget {
  const ErrorBody({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              resolveErrorMessage(error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
