import 'package:core_auth/core_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifies [GoRouter] when [authProvider] changes (hydration, sign-in, sign-out).
final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final notifier = AuthRouterRefresh();
  ref.listen<AsyncValue<AuthState>>(authProvider, (_, next) {
    notifier.notifyAuthChanged();
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final class AuthRouterRefresh extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}
