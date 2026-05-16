import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_providers.dart';
import '../state/dashboard_summary_state.dart';

class DashboardViewModel extends BaseViewModel<DashboardSummaryState> {
  @override
  Future<DashboardSummaryState> buildInitial() async {
    return DashboardSummaryState.initial();
  }

  Future<void> loadSummary() async {
    final current = valueOr(DashboardSummaryState.initial());
    state = AsyncData(
      current.copyWith(phase: UiPhase.loading, clearError: true),
    );

    final result = await ref.read(getDashboardSummaryUseCaseProvider).execute();

    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(DashboardSummaryState.success(data)),
      ApiError(:final message) => AsyncData(
        DashboardSummaryState.error(message),
      ),
      _ => state,
    };

    if (result case ApiSuccess(:final data) when data.streakDays == 0) {
      emit(
        const ShowSnackbar('Start your streak today!', type: SnackbarType.info),
      );
    }
  }
}
