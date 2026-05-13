import 'dart:async';

import 'package:core_network/core_connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _Fake implements ConnectivityContract {
  _Fake(this._controller);

  final StreamController<ConnectivityState> _controller;

  @override
  Stream<ConnectivityState> get onStatusChange => _controller.stream;

  @override
  Future<ConnectivityState> get currentStatus async =>
      ConnectivityState.offline;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('connectivityStateProvider reflects overridden stream', () async {
    final controller = StreamController<ConnectivityState>.broadcast();
    addTearDown(controller.close);

    final container = ProviderContainer(
      overrides: [
        connectivityServiceProvider.overrideWithValue(_Fake(controller)),
      ],
    );
    addTearDown(container.dispose);

    final values = <AsyncValue<ConnectivityState>>[];
    final remove = container.listen(
      connectivityStateProvider,
      (_, next) => values.add(next),
      fireImmediately: true,
    );
    addTearDown(remove.close);

    controller.add(ConnectivityState.online);
    await pumpEventQueue();

    expect(values.last.hasValue, isTrue);
    expect(values.last.requireValue, ConnectivityState.online);
  });
}
