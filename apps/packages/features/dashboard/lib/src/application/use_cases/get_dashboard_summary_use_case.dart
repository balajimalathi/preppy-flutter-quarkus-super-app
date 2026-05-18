import 'package:core_models/core_models.dart';

import '../../data/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Loads dashboard summary and maps repository failures to [AppError].
class GetDashboardSummaryUseCase {
  GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSummary> execute() async {
    final summary = (await _repository.getSummary()).getOrThrow();
    if (summary.coveragePercent < 0) {
      throw const ValidationError({
        'coveragePercent': 'Invalid coverage data from server',
      });
    }
    return summary;
  }
}
