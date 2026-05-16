/// Events emitted by [BaseViewModel]; handled by [StateViewModel] with context.
sealed class UiEvent {
  const UiEvent();
}

/// Navigate to a route (handled with GoRouter in the view layer).
final class NavigateTo extends UiEvent {
  const NavigateTo(this.route, {this.args});

  final String route;
  final Object? args;
}

/// Pop the current route.
final class NavigateBack extends UiEvent {
  const NavigateBack({this.result});

  final Object? result;
}

enum SnackbarType { info, success, warning, error }

/// Show a snackbar with a plain message.
final class ShowSnackbar extends UiEvent {
  const ShowSnackbar(this.message, {this.type = SnackbarType.info});

  final String message;
  final SnackbarType type;
}

/// Opaque dialog configuration; the view layer supplies builders.
final class ShowDialogEvent extends UiEvent {
  const ShowDialogEvent({required this.builder});

  /// `Widget Function(BuildContext)` — typed without Flutter in this package.
  final Object builder;
}

/// Bottom sheet builder; the view layer supplies builders.
final class ShowBottomSheetEvent extends UiEvent {
  const ShowBottomSheetEvent({required this.builder});

  final Object builder;
}

/// Resolve a message without BuildContext (swap to l10n later).
final class LocalizedMessage extends UiEvent {
  const LocalizedMessage(this.resolver, {this.type = SnackbarType.info});

  final String Function() resolver;
  final SnackbarType type;
}
