import 'package:core_models/core_models.dart';
import 'package:dashboard/src/application/use_cases/get_dashboard_summary_use_case.dart';
import 'package:dashboard/src/domain/entities/dashboard_summary.dart';
import 'package:dashboard/src/domain/repositories/dashboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements DashboardRepository {
  _FakeRepository(this._result);

  final Result<DashboardSummary> _result;

  @override
  Future<Result<DashboardSummary>> getSummary() async => _result;
}

void main() {
  const summary = DashboardSummary(
    greeting: 'Hi',
    streakDays: 3,
    cardsDueToday: 5,
    coveragePercent: 50,
  );

  group('GetDashboardSummaryUseCase', () {
    test('maps success to ApiResult.success', () async {
      final useCase = GetDashboardSummaryUseCase(
        _FakeRepository(const Result.success(summary)),
      );
      final result = await useCase.execute();
      expect(result, const ApiResult<DashboardSummary>.success(summary));
    });

    test('rejects negative coverage', () async {
      final useCase = GetDashboardSummaryUseCase(
        _FakeRepository(
          const Result.success(
            DashboardSummary(
              greeting: 'Hi',
              streakDays: 1,
              cardsDueToday: 1,
              coveragePercent: -1,
            ),
          ),
        ),
      );
      final result = await useCase.execute();
      expect(result, isA<ApiError<DashboardSummary>>());
    });

    test('maps repository failure to ApiResult.error', () async {
      final useCase = GetDashboardSummaryUseCase(
        _FakeRepository(
          const Result.failure(CacheFailure(message: 'no cache')),
        ),
      );
      final result = await useCase.execute();
      expect(result, isA<ApiError<DashboardSummary>>());
      expect((result as ApiError).message, 'no cache');
    });
  });
}
