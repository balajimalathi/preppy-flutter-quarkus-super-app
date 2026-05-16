import 'package:core_models/core_models.dart';

import '../entities/dashboard_summary.dart';

/// Port for loading dashboard summary (remote with offline cache).
abstract interface class DashboardRepository {
  Future<Result<DashboardSummary>> getSummary();
}
