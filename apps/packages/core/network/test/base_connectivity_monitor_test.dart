import 'dart:async';

import 'package:core_network/src/connectivity/base_connectivity_monitor.dart';
import 'package:core_network/src/connectivity/connectivity_state.dart';
import 'package:flutter_test/flutter_test.dart';

final class _TestMonitor extends BaseConnectivityMonitor {
  _TestMonitor({super.debounce = const Duration(milliseconds: 50)}) {
    bindUpstream(_controller.stream);
  }

  final _controller = StreamController<ConnectivityState>.broadcast();

  void push(ConnectivityState state) => _controller.add(state);

  Future<void> closeUpstream() => _controller.close();

  @override
  Future<ConnectivityState> get currentStatus async =>
      ConnectivityState.offline;
}

void main() {
  group('BaseConnectivityMonitor', () {
    late _TestMonitor monitor;
    late StreamSubscription<ConnectivityState> subscription;
    final emissions = <ConnectivityState>[];

    setUp(() {
      monitor = _TestMonitor();
      emissions.clear();
      subscription = monitor.onStatusChange.listen(emissions.add);
    });

    tearDown(() async {
      await subscription.cancel();
      monitor.dispose();
      await monitor.closeUpstream();
    });

    test('debounces upstream events', () async {
      monitor.push(ConnectivityState.online);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions, [ConnectivityState.online]);
    });

    test('drops consecutive duplicate states', () async {
      monitor.push(ConnectivityState.online);
      monitor.push(ConnectivityState.online);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions, [ConnectivityState.online]);
    });

    test('emits distinct states in order', () async {
      monitor.push(ConnectivityState.online);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      monitor.push(ConnectivityState.offline);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions, [ConnectivityState.online, ConnectivityState.offline]);
    });

    test('stops emitting after dispose', () async {
      final localMonitor = _TestMonitor();
      final localEmissions = <ConnectivityState>[];
      final sub = localMonitor.onStatusChange.listen(localEmissions.add);
      addTearDown(() async {
        await sub.cancel();
        localMonitor.dispose();
        await localMonitor.closeUpstream();
      });

      localMonitor.push(ConnectivityState.online);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final countAfterFirst = localEmissions.length;
      localMonitor.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(localEmissions.length, countAfterFirst);
    });
  });
}
