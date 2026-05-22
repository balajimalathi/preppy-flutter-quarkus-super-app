import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onboarding/src/application/providers/onboarding_providers.dart';
import 'package:onboarding/src/data/repositories/onboarding_repository.dart';
import 'package:onboarding/src/domain/entities/onboarding_draft.dart';
import 'package:onboarding/src/domain/entities/onboarding_profile.dart';
import 'package:onboarding/src/presentation/onboarding_screen.dart';

import '../helpers/fake_onboarding_repository.dart';

void main() {
  testWidgets('blocks submit with inline messages for required fields', (
    tester,
  ) async {
    final repository = FakeOnboardingRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.text('Save onboarding'));
    await tester.pump();

    expect(find.text('Learning target is required'), findsOneWidget);
    expect(find.text('Study level is required'), findsOneWidget);
    expect(repository.lastDraft, isNull);
  });

  testWidgets('fills form and submits repository request', (tester) async {
    final repository = FakeOnboardingRepository(
      onUpsert: (draft) async => Result.success(
        OnboardingProfile(
          onboardingCompleted: true,
          learningTarget: draft.learningTarget,
          studyLevel: draft.studyLevel!,
          goalType: draft.goalType!,
          targetDate: draft.targetDate!,
          dailyMinutes: draft.dailyMinutes,
          preferredLearningMethods: draft.preferredLearningMethods,
          notificationsEnabled: draft.notificationsEnabled,
          quietHoursStart: draft.quietHoursStart,
          quietHoursEnd: draft.quietHoursEnd,
        ),
      ),
    );
    await tester.pumpWidget(_app(repository));

    await tester.enterText(
      find.byKey(const ValueKey('learningTargetField')),
      'JEE Physics',
    );
    await tester.tap(find.text('Competitive exam').first);
    await tester.tap(find.text('Competitive exam goal').first);
    await tester.enterText(
      find.byKey(const ValueKey('targetDateField')),
      '2026-12-31',
    );
    await tester.enterText(
      find.byKey(const ValueKey('dailyMinutesField')),
      '90',
    );
    await tester.tap(find.text('MCQ'));
    await tester.tap(find.text('Flashcards'));
    await tester.tap(find.text('Save onboarding'));
    await tester.pumpAndSettle();

    final draft = repository.lastDraft;
    expect(draft, isNotNull);
    expect(draft!.learningTarget, 'JEE Physics');
    expect(draft.studyLevel, StudyLevel.competitiveExam);
    expect(draft.goalType, GoalType.competitiveExam);
    expect(draft.targetDate, DateTime(2026, 12, 31));
    expect(draft.dailyMinutes, 90);
    expect(draft.preferredLearningMethods, {
      LearningMethod.mcq,
      LearningMethod.flashcards,
    });
  });
}

Widget _app(OnboardingRepository repository) {
  return ProviderScope(
    overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: OnboardingScreen()),
  );
}
