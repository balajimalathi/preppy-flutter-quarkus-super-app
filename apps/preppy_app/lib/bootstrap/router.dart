import 'package:auth/feature_auth.dart';
import 'package:core_di/core_di.dart';
import 'package:dashboard/feature_dashboard.dart';
import 'package:ingestion/feature_ingestion.dart';
import 'package:practice/feature_practice.dart';
import 'package:pyq/feature_pyq.dart';
import 'package:syllabus/feature_syllabus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router_refresh.dart';
import 'splash_screen.dart';

/// Top-level [GoRouter] for the Preppy shell. Each feature package exposes its
/// own `routes` list which we splice in here, so adding a new feature does not
/// require touching this file beyond an import + a single entry below.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRouterRefreshProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final authAsync = ref.read(authProvider);
      return switch (authAsync) {
        AsyncLoading() => loc == '/splash' ? null : '/splash',
        AsyncError() => loc == '/login' ? null : '/login',
        AsyncData(:final value) => switch (value) {
          AuthAuthenticated() when loc == '/splash' || loc == '/login' =>
            '/dashboard',
          AuthAuthenticated() => null,
          _ when loc != '/login' => '/login',
          _ => null,
        },
      };
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ...featureAuthRoutes,
      ...featureDashboardRoutes,
      ...featureIngestionRoutes,
      ...featurePracticeRoutes,
      ...featurePyqRoutes,
      ...featureSyllabusRoutes,
    ],
  );
});
