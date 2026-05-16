import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/dashboard_summary.dart';

@immutable
class DashboardScreenState extends ScreenState<DashboardSummary> {
  const DashboardScreenState({
    super.data,
    super.error,
    super.phase,
    this.selectedTabIndex = 0,
    this.isFilterDrawerOpen = false,
  });

  const DashboardScreenState.initial()
    : selectedTabIndex = 0,
      isFilterDrawerOpen = false,
      super(phase: LoadPhase.loading);

  final int selectedTabIndex;
  final bool isFilterDrawerOpen;

  @override
  DashboardScreenState copyWith({
    DashboardSummary? data,
    AppError? error,
    bool clearError = false,
    LoadPhase? phase,
    int? selectedTabIndex,
    bool? isFilterDrawerOpen,
  }) {
    return DashboardScreenState(
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
      phase: phase ?? this.phase,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isFilterDrawerOpen: isFilterDrawerOpen ?? this.isFilterDrawerOpen,
    );
  }
}
