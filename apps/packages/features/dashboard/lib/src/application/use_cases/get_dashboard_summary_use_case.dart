import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Loads dashboard summary and maps repository failures to [AppError].
class GetDashboardSummaryUseCase extends ResultUseCase<DashboardSummary> {
  GetDashboardSummaryUseCase(
    DashboardRepository repository, {
    @visibleForTesting
    Future<Result<DashboardSummary>> Function()? callOverride,
  }) : _repository = repository,
       _callOverride = callOverride;

  @visibleForTesting
  GetDashboardSummaryUseCase.testing(
    Future<Result<DashboardSummary>> Function() callOverride,
  ) : _repository = null,
      _callOverride = callOverride;

  final DashboardRepository? _repository;
  final Future<Result<DashboardSummary>> Function()? _callOverride;

  @override
  Future<Result<DashboardSummary>> call() {
    final override = _callOverride;
    if (override != null) {
      return override();
    }
    return _repository!.getSummary();
  }

  @override
  Future<DashboardSummary> execute() async {
    final summary = await super.execute();
    if (summary.coveragePercent < 0) {
      throw const ValidationError({
        'coveragePercent': 'Invalid coverage data from server',
      });
    }
    return summary;
  }
}
