import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding/src/application/providers/onboarding_providers.dart';
import 'package:onboarding/src/application/view_models/onboarding_view_model.dart';
import 'package:onboarding/src/data/repositories/onboarding_repository.dart';
import 'package:onboarding/src/domain/entities/onboarding_draft.dart';
import 'package:onboarding/src/domain/entities/onboarding_profile.dart';

import '../helpers/fake_onboarding_repository.dart';

void main() {
  final targetDate = DateTime(2026, 12, 31);
  final savedProfile = OnboardingProfile(
    onboardingCompleted: true,
    learningTarget: 'JEE Physics',
    studyLevel: StudyLevel.competitiveExam,
    goalType: GoalType.competitiveExam,
    targetDate: targetDate,
    dailyMinutes: 90,
    preferredLearningMethods: {LearningMethod.mcq},
    notificationsEnabled: false,
  );

  test('initial state contains editable draft', () {
    final container = _container(FakeOnboardingRepository());
    addTearDown(container.dispose);

    final state = container.read(onboardingViewModelProvider);

    expect(state.phase, LoadPhase.idle);
    expect(state.data, const OnboardingDraft());
  });

  test('invalid local draft sets field errors and skips repository', () async {
    final repository = FakeOnboardingRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    await container.read(onboardingViewModelProvider.notifier).save();

    final state = container.read(onboardingViewModelProvider);
    expect(state.fieldErrors.keys, contains('learningTarget'));
    expect(state.fieldErrors.keys, contains('studyLevel'));
    expect(state.fieldErrors.keys, contains('goalType'));
    expect(state.fieldErrors.keys, contains('targetDate'));
    expect(state.fieldErrors.keys, contains('preferredLearningMethods'));
    expect(repository.calls, 0);
  });

  test('valid save stores returned profile', () async {
    final repository = FakeOnboardingRepository(
      result: Result.success(savedProfile),
    );
    final container = _container(repository);
    addTearDown(container.dispose);

    final notifier = container.read(onboardingViewModelProvider.notifier);
    _fillValidDraft(notifier, targetDate);
    await notifier.save();

    final state = container.read(onboardingViewModelProvider);
    expect(repository.calls, 1);
    expect(state.phase, LoadPhase.idle);
    expect(state.savedProfile, savedProfile);
    expect(state.hasError, isFalse);
  });

  test('repository validation error populates field errors', () async {
    final repository = FakeOnboardingRepository(
      result: const Result.failure(
        UnknownFailure(
          message: 'validation',
          code: 400,
          cause: ValidationError({'dailyMinutes': 'must be at least 5'}),
        ),
      ),
    );
    final container = _container(repository);
    addTearDown(container.dispose);

    final notifier = container.read(onboardingViewModelProvider.notifier);
    _fillValidDraft(notifier, targetDate);
    await notifier.save();

    final state = container.read(onboardingViewModelProvider);
    expect(state.fieldErrors, {'dailyMinutes': 'must be at least 5'});
    expect(state.data!.learningTarget, 'JEE Physics');
  });
}

ProviderContainer _container(OnboardingRepository repository) {
  return ProviderContainer(
    overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
  );
}

void _fillValidDraft(OnboardingViewModel notifier, DateTime targetDate) {
  notifier.updateLearningTarget('JEE Physics');
  notifier.updateStudyLevel(StudyLevel.competitiveExam);
  notifier.updateGoalType(GoalType.competitiveExam);
  notifier.updateTargetDate(targetDate);
  notifier.updateDailyMinutes(90);
  notifier.toggleLearningMethod(LearningMethod.mcq, true);
}
