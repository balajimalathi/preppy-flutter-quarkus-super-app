import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_dashboard_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../use_cases/get_dashboard_summary_use_case.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  ApiDashboardRepository.new,
);

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>(
  (ref) {
    return GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));
  },
);
