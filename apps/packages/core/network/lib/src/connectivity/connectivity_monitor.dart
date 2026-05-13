import 'package:connectivity_plus/connectivity_plus.dart';

import 'base_connectivity_monitor.dart';
import 'connectivity_state.dart';

/// Live connectivity using `connectivity_plus` (not exported from this package).
final class ConnectivityMonitor extends BaseConnectivityMonitor {
  ConnectivityMonitor({super.debounce = const Duration(milliseconds: 300)})
    : _plugin = Connectivity() {
    bindUpstream(_plugin.onConnectivityChanged.map(_mapResults));
  }

  final Connectivity _plugin;

  @override
  Future<ConnectivityState> get currentStatus async {
    try {
      return _mapResults(await _plugin.checkConnectivity());
    } on Object {
      return ConnectivityState.offline;
    }
  }

  static ConnectivityState _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectivityState.offline;
    }
    final online = results.any((r) => r != ConnectivityResult.none);
    return online ? ConnectivityState.online : ConnectivityState.offline;
  }
}
