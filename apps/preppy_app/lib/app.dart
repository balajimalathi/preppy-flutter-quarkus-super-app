import 'package:core_di/core_di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import 'bootstrap/router.dart';

class PreppyApp extends ConsumerWidget {
  const PreppyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Preppy',
      theme: theme.theme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: kDebugMode,
      builder: (context, child) =>
          _ConnectivitySnackBarScope(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Listens under [MaterialApp] so [ScaffoldMessenger] resolves. Sticky snackbar
/// while offline; short green snackbar when back online (clears the offline bar).
class _ConnectivitySnackBarScope extends ConsumerStatefulWidget {
  const _ConnectivitySnackBarScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_ConnectivitySnackBarScope> createState() =>
      _ConnectivitySnackBarScopeState();
}

class _ConnectivitySnackBarScopeState
    extends ConsumerState<_ConnectivitySnackBarScope> {
  static const _sticky = Duration(days: 365);

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ConnectivityState>>(connectivityStateProvider, (
      previous,
      next,
    ) {
      if (!context.mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      next.when(
        data: (state) {
          final prev = previous?.asData?.value;
          if (prev == state) {
            return;
          }
          if (state == ConnectivityState.online &&
              (previous == null || !previous.hasValue)) {
            return;
          }

          if (state == ConnectivityState.offline) {
            messenger
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: const Text('No internet connection'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.fixed,
                  duration: _sticky,
                ),
              );
          } else {
            messenger
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Back online'),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.fixed,
                  duration: const Duration(seconds: 2),
                ),
              );
          }
        },
        loading: () {},
        error: (_, _) {},
      );
    });

    return widget.child;
  }
}
