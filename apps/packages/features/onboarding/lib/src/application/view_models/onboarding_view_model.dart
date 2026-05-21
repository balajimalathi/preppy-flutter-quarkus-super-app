import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../providers/onboarding_providers.dart';
import '../state/onboarding_screen_state.dart';

class OnboardingViewModel
    extends BaseViewModel<OnboardingDraft, OnboardingScreenState> {
  @override
  OnboardingScreenState initialState() => const OnboardingScreenState.initial();

  @override
  void initialize() {}

  void updateLearningTarget(String value) {
    _updateDraft((draft) => draft.copyWith(learningTarget: value));
  }

  void updateStudyLevel(StudyLevel value) {
    _updateDraft((draft) => draft.copyWith(studyLevel: value));
  }

  void updateGoalType(GoalType value) {
    _updateDraft((draft) => draft.copyWith(goalType: value));
  }

  void updateTargetDate(DateTime value) {
    _updateDraft((draft) => draft.copyWith(targetDate: value));
  }

  void updateDailyMinutes(int value) {
    _updateDraft((draft) => draft.copyWith(dailyMinutes: value));
  }

  void updateNotificationsEnabled(bool value) {
    _updateDraft((draft) {
      return draft.copyWith(
        notificationsEnabled: value,
        clearQuietHoursStart: !value,
        clearQuietHoursEnd: !value,
      );
    });
  }

  void updateQuietHours({String? start, String? end}) {
    _updateDraft((draft) {
      return draft.copyWith(quietHoursStart: start, quietHoursEnd: end);
    });
  }

  void toggleLearningMethod(LearningMethod method, bool selected) {
    _updateDraft((draft) {
      final methods = {...draft.preferredLearningMethods};
      if (selected) {
        methods.add(method);
      } else {
        methods.remove(method);
      }
      return draft.copyWith(preferredLearningMethods: methods);
    });
  }

  Future<void> save() async {
    final draft = state.data ?? const OnboardingDraft();
    final fieldErrors = _validate(draft);
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        phase: LoadPhase.idle,
        clearError: true,
        clearSavedProfile: true,
      );
      return;
    }

    await runAction(() async {
      state = state.copyWith(
        phase: LoadPhase.loading,
        fieldErrors: const {},
        clearError: true,
        clearSavedProfile: true,
      );
      try {
        final profile = await ref
            .read(saveOnboardingUseCaseProvider)
            .execute(draft);
        return state.copyWith(
          phase: LoadPhase.idle,
          savedProfile: profile,
          clearError: true,
        );
      } on ValidationError catch (error) {
        return state.copyWith(
          phase: LoadPhase.idle,
          fieldErrors: error.fieldErrors,
          error: error,
        );
      }
    });
  }

  void _updateDraft(OnboardingDraft Function(OnboardingDraft draft) update) {
    state = state.copyWith(
      data: update(state.data ?? const OnboardingDraft()),
      fieldErrors: const {},
      clearError: true,
      clearSavedProfile: true,
    );
  }

  Map<String, String> _validate(OnboardingDraft draft) {
    final errors = <String, String>{};
    if (draft.learningTarget.trim().isEmpty) {
      errors['learningTarget'] = 'Learning target is required';
    }
    if (draft.studyLevel == null) {
      errors['studyLevel'] = 'Study level is required';
    }
    if (draft.goalType == null) {
      errors['goalType'] = 'Goal type is required';
    }
    if (draft.targetDate == null) {
      errors['targetDate'] = 'Target date is required';
    }
    if (draft.dailyMinutes < 5 || draft.dailyMinutes > 480) {
      errors['dailyMinutes'] = 'Daily minutes must be between 5 and 480';
    }
    if (draft.preferredLearningMethods.isEmpty) {
      errors['preferredLearningMethods'] =
          'Choose at least one learning method';
    }
    if (draft.notificationsEnabled &&
        ((draft.quietHoursStart == null) != (draft.quietHoursEnd == null))) {
      errors['quietHoursStart'] =
          'Quiet hours start and end must be provided together';
    }
    if (draft.quietHoursStart != null &&
        draft.quietHoursStart == draft.quietHoursEnd) {
      errors['quietHoursStart'] =
          'Quiet hours start and end must be different';
    }
    return errors;
  }
}

final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, OnboardingScreenState>(
      OnboardingViewModel.new,
    );
