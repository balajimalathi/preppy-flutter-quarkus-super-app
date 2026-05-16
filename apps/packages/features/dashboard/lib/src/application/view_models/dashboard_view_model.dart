import 'package:core_state/core_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';
import '../state/dashboard_screen_state.dart';

class DashboardViewModel
    extends BaseViewModel<DashboardSummary, DashboardScreenState> {
  @override
  DashboardScreenState initialState() => const DashboardScreenState.initial();

  @override
  void initialize() => Future.microtask(load);

  Future<void> load() => runAction(() async {
    state = state.copyWith(phase: LoadPhase.loading);
    final summary = await ref
        .read(getDashboardSummaryUseCaseProvider)
        .execute();
    return state.copyWith(
      data: summary,
      phase: LoadPhase.idle,
      clearError: true,
    );
  });

  Future<void> refresh() => runAction(() async {
    state = state.copyWith(phase: LoadPhase.refreshing);
    final summary = await ref
        .read(getDashboardSummaryUseCaseProvider)
        .execute();
    return state.copyWith(
      data: summary,
      phase: LoadPhase.idle,
      clearError: true,
    );
  });

  void selectTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardScreenState>(
      DashboardViewModel.new,
    );
