import 'package:go_router/go_router.dart';

import 'ingestion_screen.dart';

final List<RouteBase> featureIngestionRoutes = [
  GoRoute(
    path: '/ingestion',
    builder: (context, state) => const IngestionScreen(),
  ),
];
