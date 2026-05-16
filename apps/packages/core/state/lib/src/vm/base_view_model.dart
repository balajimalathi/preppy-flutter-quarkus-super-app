import 'package:core_models/core_models.dart';
import 'package:riverpod/riverpod.dart';

import '../screen/load_phase.dart';
import '../screen/screen_state.dart';

/// [Notifier] base for feature ViewModels backed by [ScreenState].
abstract class BaseViewModel<S, T extends ScreenState<S>> extends Notifier<T> {
  /// Subclasses return their feature [ScreenState] in loading phase.
  T initialState();

  /// Called once from [build]. Defer async work with [Future.microtask].
  void initialize();

  @override
  T build() {
    initialize();
    return initialState();
  }

  S? get currentData => state.data;

  S dataOr(S fallback) => state.data ?? fallback;

  /// Runs an async mutation and applies the returned [ScreenState].
  Future<void> runAction(Future<T> Function() action) async {
    try {
      state = await action();
    } catch (e, _) {
      state =
          state.copyWith(
                phase: LoadPhase.idle,
                error: e is AppError ? e : UnknownError(e),
              )
              as T;
    }
  }
}
