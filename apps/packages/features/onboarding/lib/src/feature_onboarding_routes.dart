import 'package:go_router/go_router.dart';

import 'presentation/onboarding_screen.dart';

final List<RouteBase> featureOnboardingRoutes = [
  GoRoute(
    path: '/onboarding',
    builder: (context, state) =>
        OnboardingScreen(onSaved: () => context.go('/dashboard')),
  ),
];
