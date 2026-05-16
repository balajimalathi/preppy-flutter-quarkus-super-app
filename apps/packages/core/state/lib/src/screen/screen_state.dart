import 'package:core_models/core_models.dart';
import 'package:meta/meta.dart';

import 'load_phase.dart';

/// Screen-level state: domain [data], typed [error], and [phase].
@immutable
class ScreenState<S> {
  const ScreenState({
    this.data,
    this.error,
    this.phase = LoadPhase.idle,
  });

  const ScreenState.initial() : this(phase: LoadPhase.loading);

  final S? data;
  final AppError? error;
  final LoadPhase phase;

  bool get isLoading => phase == LoadPhase.loading;
  bool get isRefreshing => phase == LoadPhase.refreshing;
  bool get hasData => data != null;
  bool get hasError => error != null;

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
