import 'package:riverpod/riverpod.dart';

/// Thin [AsyncNotifier] base with safe access while [state] is still loading.
abstract class BaseViewModel<S> extends AsyncNotifier<S> {
  /// Feature state when [state] is [AsyncData]; safe during [AsyncLoading].
  S? get currentValue => state.asData?.value;

  /// [currentValue] or [fallback] — use instead of [AsyncValue.requireValue] in actions.
  S valueOr(S fallback) => currentValue ?? fallback;

  @override
  Future<S> build() async => buildInitial();

  /// Subclasses return the initial value (often by fetching).
  Future<S> buildInitial();
}
