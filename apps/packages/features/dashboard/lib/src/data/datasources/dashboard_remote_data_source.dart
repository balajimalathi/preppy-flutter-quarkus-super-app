import 'package:core_models/core_models.dart';

import '../../domain/entities/dashboard_summary.dart';

abstract interface class DashboardRemoteDataSource {
  Future<Result<DashboardSummary>> fetchSummary();
}
