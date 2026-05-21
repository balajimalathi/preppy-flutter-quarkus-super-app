import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../application/state/onboarding_screen_state.dart';
import '../application/view_models/onboarding_view_model.dart';
import '../domain/entities/onboarding_draft.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);
    ref.listen(onboardingViewModelProvider, (previous, next) {
      if (previous?.savedProfile == null && next.savedProfile != null) {
        onSaved?.call();
      }
    });

    final draft = state.data ?? const OnboardingDraft();
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your learning profile')),
      body: _OnboardingForm(state: state, draft: draft),
    );
  }
}

class _OnboardingForm extends ConsumerWidget {
  const _OnboardingForm({required this.state, required this.draft});

  final OnboardingScreenState state;
  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingViewModelProvider.notifier);
    final errors = state.fieldErrors;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (state.error case final AppError error)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(resolveErrorMessage(error)),
          ),
        TextField(
          key: const ValueKey('learningTargetField'),
          decoration: InputDecoration(
            labelText: 'Learning target',
            errorText: errors['learningTarget'],
          ),
          onChanged: notifier.updateLearningTarget,
        ),
        const SizedBox(height: 16),
        _SectionError(message: errors['studyLevel']),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('School'),
              selected: draft.studyLevel == StudyLevel.school,
              onSelected: (_) => notifier.updateStudyLevel(StudyLevel.school),
            ),
            ChoiceChip(
              label: const Text('Undergraduate'),
              selected: draft.studyLevel == StudyLevel.undergraduate,
              onSelected: (_) =>
                  notifier.updateStudyLevel(StudyLevel.undergraduate),
            ),
            ChoiceChip(
              label: const Text('Competitive exam'),
              selected: draft.studyLevel == StudyLevel.competitiveExam,
              onSelected: (_) =>
                  notifier.updateStudyLevel(StudyLevel.competitiveExam),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionError(message: errors['goalType']),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Subject'),
              selected: draft.goalType == GoalType.subject,
              onSelected: (_) => notifier.updateGoalType(GoalType.subject),
            ),
            ChoiceChip(
              label: const Text('Course'),
              selected: draft.goalType == GoalType.course,
              onSelected: (_) => notifier.updateGoalType(GoalType.course),
            ),
            ChoiceChip(
              label: const Text('Competitive exam goal'),
              selected: draft.goalType == GoalType.competitiveExam,
              onSelected: (_) =>
                  notifier.updateGoalType(GoalType.competitiveExam),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('targetDateField'),
          decoration: InputDecoration(
            labelText: 'Target date',
            hintText: 'YYYY-MM-DD',
            errorText: errors['targetDate'],
          ),
          onChanged: (value) {
            final parsed = DateTime.tryParse(value);
            if (parsed != null) {
              notifier.updateTargetDate(parsed);
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('dailyMinutesField'),
          decoration: InputDecoration(
            labelText: 'Daily minutes',
            errorText: errors['dailyMinutes'],
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null) {
              notifier.updateDailyMinutes(parsed);
            }
          },
        ),
        const SizedBox(height: 16),
        _SectionError(message: errors['preferredLearningMethods']),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Reading'),
              selected: draft.preferredLearningMethods.contains(
                LearningMethod.reading,
              ),
              onSelected: (selected) => notifier.toggleLearningMethod(
                LearningMethod.reading,
                selected,
              ),
            ),
            FilterChip(
              label: const Text('MCQ'),
              selected: draft.preferredLearningMethods.contains(
                LearningMethod.mcq,
              ),
              onSelected: (selected) =>
                  notifier.toggleLearningMethod(LearningMethod.mcq, selected),
            ),
            FilterChip(
              label: const Text('Flashcards'),
              selected: draft.preferredLearningMethods.contains(
                LearningMethod.flashcards,
              ),
              onSelected: (selected) => notifier.toggleLearningMethod(
                LearningMethod.flashcards,
                selected,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable notifications'),
          value: draft.notificationsEnabled,
          onChanged: notifier.updateNotificationsEnabled,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: state.phase == LoadPhase.loading
              ? null
              : () => notifier.save(),
          child: state.phase == LoadPhase.loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save onboarding'),
        ),
      ],
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        message!,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
