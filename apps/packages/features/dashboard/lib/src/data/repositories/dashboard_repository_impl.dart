import 'package:core_models/core_models.dart';
import 'package:core_network/core_connectivity.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../datasources/dashboard_remote_data_source.dart';

final class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required DashboardRemoteDataSource remote,
    required DashboardLocalDataSource local,
    required ConnectivityContract connectivity,
  }) : _remote = remote,
       _local = local,
       _connectivity = connectivity;

  final DashboardRemoteDataSource _remote;
  final DashboardLocalDataSource _local;
  final ConnectivityContract _connectivity;

  @override
  Future<Result<DashboardSummary>> getSummary() async {
    final status = await _connectivity.currentStatus;
    if (status == ConnectivityState.offline) {
      final cached = await _local.getSummary();
      if (cached != null) {
        return Result.success(cached);
      }
      return const Result.failure(
        CacheFailure(message: 'No cached dashboard data available'),
      );
    }

    final remote = await _remote.fetchSummary();
    if (remote case Success(:final data)) {
      await _local.saveSummary(data);
    }
    return remote;
  }
}
