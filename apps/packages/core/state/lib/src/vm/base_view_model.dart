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

  /// Runs an async mutation and stores its returned [ScreenState].
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

  /// Initial load: sets [LoadPhase.loading], then stores [fetch] result.
  Future<void> loadData(Future<S> Function() fetch) =>
      _fetchWithPhase(LoadPhase.loading, fetch);

  /// Pull-to-refresh: sets [LoadPhase.refreshing], then stores [fetch] result.
  Future<void> refreshData(Future<S> Function() fetch) =>
      _fetchWithPhase(LoadPhase.refreshing, fetch);

  Future<void> _fetchWithPhase(LoadPhase phase, Future<S> Function() fetch) =>
      runAction(() async {
        state = state.copyWith(phase: phase) as T;
        final data = await fetch();
        return state.copyWith(
              data: data,
              phase: LoadPhase.idle,
              clearError: true,
            )
            as T;
      });
}
