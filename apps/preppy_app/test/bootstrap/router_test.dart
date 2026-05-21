import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preppy_app/bootstrap/router.dart';
import 'package:preppy_app/bootstrap/session_gate_provider.dart';

void main() {
  testWidgets('incomplete authenticated users are redirected to onboarding', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sessionGateProvider.overrideWithValue(
          const SessionGateState(target: SessionRouteTarget.onboarding),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    await tester.pumpWidget(_app(container, router));

    router.go('/dashboard');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/onboarding');
  });

  testWidgets('completed users leave login for dashboard', (tester) async {
    final container = ProviderContainer(
      overrides: [
        sessionGateProvider.overrideWithValue(
          const SessionGateState(target: SessionRouteTarget.dashboard),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    await tester.pumpWidget(_app(container, router));

    router.go('/login');
    await tester.pump();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/dashboard');
  });
}

Widget _app(ProviderContainer container, GoRouter router) {
  return UncontrolledProviderScope(
    container: container,
    child: _RouterHost(router: router),
  );
}

class _RouterHost extends ConsumerWidget {
  const _RouterHost({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(routerConfig: router);
  }
}
