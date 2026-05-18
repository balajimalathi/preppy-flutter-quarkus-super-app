import 'package:core_models/core_models.dart';
import 'package:dashboard/src/application/use_cases/get_dashboard_summary_use_case.dart';
import 'package:dashboard/src/data/repositories/dashboard_repository.dart';
import 'package:dashboard/src/domain/entities/dashboard_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_dashboard_summary_use_case_test.mocks.dart';

@GenerateMocks([DashboardRepository])
void main() {
  provideDummy<Result<DashboardSummary>>(
    const Result.failure(UnknownFailure(message: 'dummy')),
  );

  const summary = DashboardSummary(
    greeting: 'Hi',
    streakDays: 3,
    cardsDueToday: 5,
    coveragePercent: 50,
  );

  late MockDashboardRepository repository;
  late GetDashboardSummaryUseCase useCase;

  setUp(() {
    repository = MockDashboardRepository();
    useCase = GetDashboardSummaryUseCase(repository);
  });

  group('GetDashboardSummaryUseCase', () {
    test('returns summary on success', () async {
      when(
        repository.getSummary(),
      ).thenAnswer((_) async => const Result.success(summary));

      final result = await useCase.execute();

      expect(result, summary);
      verify(repository.getSummary()).called(1);
    });

    test('throws ValidationError for negative coverage', () async {
      when(repository.getSummary()).thenAnswer(
        (_) async => const Result.success(
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
      when(repository.getSummary()).thenAnswer(
        (_) async => const Result.failure(CacheFailure(message: 'no cache')),
      );

      await expectLater(useCase.execute(), throwsA(isA<NetworkError>()));
    });
  });
}
