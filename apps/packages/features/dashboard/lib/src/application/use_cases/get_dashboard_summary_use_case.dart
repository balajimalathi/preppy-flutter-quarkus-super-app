import 'package:core_models/core_models.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Loads dashboard summary and maps repository failures to [AppError].
class GetDashboardSummaryUseCase {
  GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSummary> execute() async {
    final result = await _repository.getSummary();
    return switch (result) {
      Success(:final data) when data.coveragePercent < 0 =>
        throw const ValidationError({
          'coveragePercent': 'Invalid coverage data from server',
        }),
      Success(:final data) => data,
      FailureResult(:final failure) => throw failure.toAppError(),
    };
  }
}
