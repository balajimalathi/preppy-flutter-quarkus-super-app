import 'package:go_router/go_router.dart';

import 'pyq_screen.dart';

final List<RouteBase> featurePyqRoutes = [
  GoRoute(path: '/pyq', builder: (context, state) => const PyqScreen()),
];
