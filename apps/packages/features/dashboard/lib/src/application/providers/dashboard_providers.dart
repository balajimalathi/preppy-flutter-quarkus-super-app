import 'package:core_di/core_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/dashboard_local_data_source.dart';
import '../../data/datasources/dashboard_local_data_source_impl.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/datasources/dashboard_remote_data_source_impl.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../use_cases/get_dashboard_summary_use_case.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSourceImpl(ref.watch(dioProvider));
});

final dashboardLocalDataSourceProvider = Provider<DashboardLocalDataSource>((
  ref,
) {
  return DashboardLocalDataSourceImpl();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remote: ref.watch(dashboardRemoteDataSourceProvider),
    local: ref.watch(dashboardLocalDataSourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>(
  (ref) {
    return GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));
  },
);
