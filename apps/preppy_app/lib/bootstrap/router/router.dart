import 'package:auth/feature_auth.dart';
import 'package:dashboard/feature_dashboard.dart';
import 'package:dev_tools/feature_dev_tools.dart';
import 'package:ingestion/feature_ingestion.dart';
import 'package:onboarding/feature_onboarding.dart';
import 'package:practice/feature_practice.dart';
import 'package:pyq/feature_pyq.dart';
import 'package:syllabus/feature_syllabus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router_refresh.dart';
import 'session_gate_provider.dart';
import '../splash_screen.dart';

/// Top-level [GoRouter] for the Preppy shell. Each feature package exposes its
/// own `routes` list which we splice in here, so adding a new feature does not
/// require touching this file beyond an import + a single entry below.
final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(sessionGateProvider);
  final refresh = ref.watch(authRouterRefreshProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final gate = ref.read(sessionGateProvider);
      return switch (gate.target) {
        SessionRouteTarget.splash => loc == '/splash' ? null : '/splash',
        SessionRouteTarget.login => loc == '/login' ? null : '/login',
        SessionRouteTarget.onboarding =>
          loc == '/onboarding' ? null : '/onboarding',
        SessionRouteTarget.dashboard
            when loc == '/splash' || loc == '/login' || loc == '/onboarding' =>
          '/dashboard',
        SessionRouteTarget.dashboard => null,
      };
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ...featureAuthRoutes,
      ...featureDashboardRoutes,
      ...featureDevToolsRoutes,
      ...featureIngestionRoutes,
      ...featureOnboardingRoutes(ref),
      ...featurePracticeRoutes,
      ...featurePyqRoutes,
      ...featureSyllabusRoutes,
    ],
  );
});
