import 'package:go_router/go_router.dart';

import 'practice_screen.dart';

final List<RouteBase> featurePracticeRoutes = [
  GoRoute(
    path: '/practice',
    builder: (context, state) => const PracticeScreen(),
  ),
];
