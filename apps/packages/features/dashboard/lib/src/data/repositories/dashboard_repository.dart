import 'package:core_models/core_models.dart';

import '../../domain/entities/dashboard_summary.dart';

/// Contract for loading dashboard summary (mockable in tests).
abstract interface class DashboardRepository {
  Future<Result<DashboardSummary>> getSummary();
}
