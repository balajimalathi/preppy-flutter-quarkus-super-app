import 'package:core_models/core_models.dart';
import 'package:dashboard/src/application/use_cases/get_dashboard_summary_use_case.dart';
import 'package:dashboard/src/domain/entities/dashboard_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const summary = DashboardSummary(
    greeting: 'Hi',
    streakDays: 3,
    cardsDueToday: 5,
    coveragePercent: 50,
  );

  GetDashboardSummaryUseCase useCaseWith(Result<DashboardSummary> result) {
    return GetDashboardSummaryUseCase.testing(() async => result);
  }

  group('GetDashboardSummaryUseCase', () {
    test('returns summary on success', () async {
      final useCase = useCaseWith(const Result.success(summary));
      final result = await useCase.execute();
      expect(result, summary);
    });

    test('throws ValidationError for negative coverage', () async {
      final useCase = useCaseWith(
        const Result.success(
          DashboardSummary(
            greeting: 'Hi',
            streakDays: 1,
            cardsDueToday: 1,
            coveragePercent: -1,
          ),
        ),
      );
      await expectLater(useCase.execute(), throwsA(isA<ValidationError>()));
    });

    test('throws AppError on repository failure', () async {
      final useCase = useCaseWith(
        const Result.failure(CacheFailure(message: 'no cache')),
      );
      await expectLater(useCase.execute(), throwsA(isA<NetworkError>()));
    });
  });
}
