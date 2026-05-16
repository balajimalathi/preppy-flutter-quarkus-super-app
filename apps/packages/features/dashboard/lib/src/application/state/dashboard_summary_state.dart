import 'package:core_state/core_state.dart';

import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryState {
  const DashboardSummaryState({
    required this.phase,
    this.summary,
    this.errorMessage,
  });

  factory DashboardSummaryState.initial() {
    return const DashboardSummaryState(phase: UiPhase.initial);
  }

  factory DashboardSummaryState.success(DashboardSummary summary) {
    return DashboardSummaryState(phase: UiPhase.success, summary: summary);
  }

  factory DashboardSummaryState.error(String message) {
    return DashboardSummaryState(phase: UiPhase.error, errorMessage: message);
  }

  final UiPhase phase;
  final DashboardSummary? summary;
  final String? errorMessage;

  DashboardSummaryState copyWith({
    UiPhase? phase,
    DashboardSummary? summary,
    String? errorMessage,
    bool clearSummary = false,
    bool clearError = false,
  }) {
    return DashboardSummaryState(
      phase: phase ?? this.phase,
      summary: clearSummary ? null : (summary ?? this.summary),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
