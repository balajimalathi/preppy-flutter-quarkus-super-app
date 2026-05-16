import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';

class DashboardViewModel extends BaseViewModel<DashboardSummary> {
  
  @override
  Future<DashboardSummary> buildInitial() async {
    final result = await ref.read(getDashboardSummaryUseCaseProvider).execute();
    return switch (result) {
      ApiSuccess(:final data) => data,
      ApiError(:final message) => throw StateError(message),
      _ => throw StateError('Unexpected result'),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(buildInitial);
  }
}
