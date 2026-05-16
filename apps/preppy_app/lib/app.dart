import 'dart:developer' as developer;

import 'package:core_di/core_di.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import 'bootstrap/preppy_fcm_token_sync.dart';
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
      builder: (context, child) => _FcmTokenSyncScope(
        child: _ConnectivitySnackBarScope(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
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
  void initState() {
    super.initState();
    // Request notification permissions after the app has started and the
    // Activity is fully visible, otherwise the prompt won't show on Android 13+.
    Future.microtask(() async {
      final granted = await CoreNotificationsFacade.instance
          .requestPermission();
      if (kDebugMode) {
        developer.log(
          'notification permission: ${granted ? "granted" : "denied"}',
          name: 'PreppyPush',
        );
      }
    });
  }

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

/// Syncs FCM token to the backend after sign-in and when the token refreshes.
class _FcmTokenSyncScope extends ConsumerStatefulWidget {
  const _FcmTokenSyncScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_FcmTokenSyncScope> createState() => _FcmTokenSyncScopeState();
}

class _FcmTokenSyncScopeState extends ConsumerState<_FcmTokenSyncScope> {
  @override
  void initState() {
    super.initState();
    PreppyFcmTokenSync.onTokenPendingSync = _syncToken;
    FirebaseAuth.instance.authStateChanges().listen((_) {
      _syncToken();
    });
    Future.microtask(_syncToken);
  }

  @override
  void dispose() {
    PreppyFcmTokenSync.onTokenPendingSync = null;
    super.dispose();
  }

  Future<void> _syncToken() async {
    if (!mounted) {
      return;
    }
    final dio = ref.read(dioProvider);
    await PreppyFcmTokenSync.trySync(dio);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
