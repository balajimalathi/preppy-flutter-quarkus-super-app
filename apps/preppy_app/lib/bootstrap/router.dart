import 'package:auth/feature_auth.dart';
import 'package:dashboard/feature_dashboard.dart';
import 'package:ingestion/feature_ingestion.dart';
import 'package:practice/feature_practice.dart';
import 'package:pyq/feature_pyq.dart';
import 'package:syllabus/feature_syllabus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Top-level [GoRouter] for the Preppy shell. Each feature package exposes its
/// own `routes` list which we splice in here, so adding a new feature does not
/// require touching this file beyond an import + a single entry below.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ...featureAuthRoutes,
      ...featureDashboardRoutes,
      ...featureIngestionRoutes,
      ...featurePracticeRoutes,
      ...featurePyqRoutes,
      ...featureSyllabusRoutes,
    ],
  );
});
