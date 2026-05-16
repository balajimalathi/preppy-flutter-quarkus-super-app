import '../../domain/entities/dashboard_summary.dart';

abstract interface class DashboardLocalDataSource {
  Future<DashboardSummary?> getSummary();

  Future<void> saveSummary(DashboardSummary summary);
}
