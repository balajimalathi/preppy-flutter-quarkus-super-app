import 'package:dashboard/src/status_screen.dart';
import 'package:go_router/go_router.dart';

import 'presentation/dashboard_screen.dart';

final List<RouteBase> featureDashboardRoutes = [
  GoRoute(
    path: '/dashboard',
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(path: '/status', builder: (context, state) => const StatusScreen()),
];
