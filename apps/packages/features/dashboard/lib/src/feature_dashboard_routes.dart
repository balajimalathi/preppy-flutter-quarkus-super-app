import 'package:go_router/go_router.dart';

import 'dashboard_screen.dart';

final List<RouteBase> featureDashboardRoutes = [
  GoRoute(
    path: '/dashboard',
    builder: (context, state) => const DashboardScreen(),
  ),
];
