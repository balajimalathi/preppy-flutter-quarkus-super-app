import 'package:core_models/core_models.dart';
import 'package:core_network/core_connectivity.dart';
import 'package:dashboard/src/data/datasources/dashboard_local_data_source.dart';
import 'package:dashboard/src/data/datasources/dashboard_remote_data_source.dart';
import 'package:dashboard/src/data/repositories/dashboard_repository_impl.dart';
import 'package:dashboard/src/domain/entities/dashboard_summary.dart';
import 'package:flutter_test/flutter_test.dart';

const _summary = DashboardSummary(
  greeting: 'Cached',
  streakDays: 2,
  cardsDueToday: 10,
  coveragePercent: 40,
);

final class _FakeRemote implements DashboardRemoteDataSource {
  _FakeRemote(this.result);

  final Result<DashboardSummary> result;
  DashboardSummary? saved;

  @override
  Future<Result<DashboardSummary>> fetchSummary() async => result;
}

final class _FakeLocal implements DashboardLocalDataSource {
  DashboardSummary? stored;

  @override
  Future<DashboardSummary?> getSummary() async => stored;

  @override
  Future<void> saveSummary(DashboardSummary summary) async {
    stored = summary;
  }
}

final class _FakeConnectivity implements ConnectivityContract {
  _FakeConnectivity(this._status);

  ConnectivityState _status;

  set status(ConnectivityState value) => _status = value;

  @override
  Future<ConnectivityState> get currentStatus async => _status;

  @override
  Stream<ConnectivityState> get onStatusChange => Stream.value(_status);
}

void main() {
  group('DashboardRepositoryImpl', () {
    test('offline returns cached summary', () async {
      final local = _FakeLocal()..stored = _summary;
      final repo = DashboardRepositoryImpl(
        remote: _FakeRemote(const Result.failure(NetworkFailure(message: 'x'))),
        local: local,
        connectivity: _FakeConnectivity(ConnectivityState.offline),
      );

      final result = await repo.getSummary();
      expect(result, const Result.success(_summary));
    });

    test('offline without cache returns CacheFailure', () async {
      final repo = DashboardRepositoryImpl(
        remote: _FakeRemote(const Result.failure(NetworkFailure(message: 'x'))),
        local: _FakeLocal(),
        connectivity: _FakeConnectivity(ConnectivityState.offline),
      );

      final result = await repo.getSummary();
      expect(result, isA<FailureResult<DashboardSummary>>());
    });

    test('online success persists to local', () async {
      final local = _FakeLocal();
      final remote = _FakeRemote(const Result.success(_summary));
      final repo = DashboardRepositoryImpl(
        remote: remote,
        local: local,
        connectivity: _FakeConnectivity(ConnectivityState.online),
      );

      final result = await repo.getSummary();
      expect(result, const Result.success(_summary));
      expect(local.stored, _summary);
    });
  });
}
