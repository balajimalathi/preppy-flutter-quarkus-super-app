import 'package:core_network/core_connectivity.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

final class _TestRepo with DioAware, ConnectivityAware {
  _TestRepo(this.ref);

  @override
  final Ref ref;
}

final _testRepoProvider = Provider<_TestRepo>((ref) => _TestRepo(ref));

final class _FakeConnectivity implements ConnectivityContract {
  @override
  Future<ConnectivityState> get currentStatus async => ConnectivityState.online;

  @override
  Stream<ConnectivityState> get onStatusChange => const Stream.empty();

  @override
  void dispose() {}
}

void main() {
  test(
    'DioAware and ConnectivityAware resolve from ProviderContainer overrides',
    () {
      final dio = Dio(BaseOptions(baseUrl: 'https://override.test'));
      final fakeConnectivity = _FakeConnectivity();
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          connectivityServiceProvider.overrideWithValue(fakeConnectivity),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(_testRepoProvider);

      expect(identical(repo.dio, dio), isTrue);
      expect(identical(repo.connectivity, fakeConnectivity), isTrue);
    },
  );
}
