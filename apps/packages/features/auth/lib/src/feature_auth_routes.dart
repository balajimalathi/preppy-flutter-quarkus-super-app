import 'package:go_router/go_router.dart';

import 'login_screen.dart';

final List<RouteBase> featureAuthRoutes = [
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
];
