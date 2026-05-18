import 'package:core_models/core_models.dart';
import 'package:meta/meta.dart';

import 'load_phase.dart';

/// Screen-level state: domain [data], typed [error], and [phase].
@immutable
class ScreenState<S> {
  const ScreenState({this.data, this.error, this.phase = LoadPhase.idle});

  /// Convenience initial state for screens that start with a blocking load.
  const ScreenState.initial() : this(phase: LoadPhase.loading);

  final S? data;
  final AppError? error;
  final LoadPhase phase;

  /// True while the screen is in its initial or blocking load.
  bool get isLoading => phase == LoadPhase.loading;

  /// True while a non-blocking refresh is running.
  bool get isRefreshing => phase == LoadPhase.refreshing;

  /// True when [data] is non-null.
  bool get hasData => data != null;

  /// True when [error] is non-null.
  bool get hasError => error != null;

  /// Returns a new state with selected fields replaced.
  ScreenState<S> copyWith({
    S? data,
    AppError? error,
    bool clearError = false,
    LoadPhase? phase,
  }) {
    return ScreenState(
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
      phase: phase ?? this.phase,
    );
  }
}
