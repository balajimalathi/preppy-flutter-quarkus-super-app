import 'package:feature_auth/feature_auth.dart';
import 'package:feature_dashboard/feature_dashboard.dart';
import 'package:feature_ingestion/feature_ingestion.dart';
import 'package:feature_practice/feature_practice.dart';
import 'package:feature_pyq/feature_pyq.dart';
import 'package:feature_syllabus/feature_syllabus.dart';
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
