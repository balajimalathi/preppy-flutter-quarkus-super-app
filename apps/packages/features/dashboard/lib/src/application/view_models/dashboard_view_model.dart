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

  Future<void> load() =>
      loadData(() => ref.read(getDashboardSummaryUseCaseProvider).execute());

  Future<void> refresh() =>
      refreshData(() => ref.read(getDashboardSummaryUseCaseProvider).execute());

  void selectTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardScreenState>(
      DashboardViewModel.new,
    );
