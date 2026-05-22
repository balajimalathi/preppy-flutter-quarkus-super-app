import 'package:core_auth/core_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/onboarding_screen.dart';

/// Routes for this feature. [ref] comes from the shell [appRouterProvider].
List<RouteBase> featureOnboardingRoutes(Ref ref) => [
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => OnboardingScreen(
      onSaved: () async {
        await ref.read(authProvider.notifier).refreshAuthenticatedProfile();
        if (context.mounted) {
          context.go('/dashboard');
        }
      },
    ),
  ),
];
