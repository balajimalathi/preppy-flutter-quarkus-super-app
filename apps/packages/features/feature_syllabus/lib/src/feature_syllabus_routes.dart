import 'package:go_router/go_router.dart';

import 'syllabus_screen.dart';

final List<RouteBase> featureSyllabusRoutes = [
  GoRoute(
    path: '/syllabus',
    builder: (context, state) => const SyllabusScreen(),
  ),
];
