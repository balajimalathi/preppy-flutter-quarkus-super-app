import 'package:riverpod/riverpod.dart';

import 'connectivity_contract.dart';
import 'connectivity_monitor.dart';
import 'connectivity_state.dart';

final connectivityServiceProvider = Provider<ConnectivityContract>((ref) {
  final monitor = ConnectivityMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});

final class ConnectivityNotifier extends StreamNotifier<ConnectivityState> {
  @override
  Stream<ConnectivityState> build() {
    return ref.watch(connectivityServiceProvider).onStatusChange;
  }
}

/// Watches [ConnectivityNotifier]; exposed state is [AsyncValue<ConnectivityState>].
final connectivityStateProvider =
    StreamNotifierProvider<ConnectivityNotifier, ConnectivityState>(
  ConnectivityNotifier.new,
);
