import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter/foundation.dart';

@immutable
class SyllabusListScreenState extends ScreenState<List<SyllabusItem>> {
  const SyllabusListScreenState({super.data, super.error, super.phase});

  const SyllabusListScreenState.initial() : super(phase: LoadPhase.loading);

  @override
  SyllabusListScreenState copyWith({
    List<SyllabusItem>? data,
    AppError? error,
    bool clearError = false,
    LoadPhase? phase,
  }) {
    return SyllabusListScreenState(
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
      phase: phase ?? this.phase,
    );
  }
}
