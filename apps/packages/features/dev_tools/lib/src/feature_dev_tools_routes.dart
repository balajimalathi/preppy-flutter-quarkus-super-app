import 'package:go_router/go_router.dart';

import 'presentation/status_screen.dart';

final List<RouteBase> featureDevToolsRoutes = [
  GoRoute(path: '/status', builder: (context, state) => const StatusScreen()),
];
