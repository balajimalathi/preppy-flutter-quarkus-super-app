import 'package:core_models/core_models.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Loads dashboard summary and applies domain rules before UI mapping.
class GetDashboardSummaryUseCase {
  GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  Future<ApiResult<DashboardSummary>> execute() async {
    final result = await _repository.getSummary();
    return switch (result) {
      Success(:final data) when data.coveragePercent < 0 =>
        const ApiResult.error(message: 'Invalid coverage data from server'),
      Success() => result.toApiResult(),
      FailureResult() => result.toApiResult(),
    };
  }
}
