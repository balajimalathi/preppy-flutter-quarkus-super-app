import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/entities/onboarding_profile.dart';

@immutable
class OnboardingScreenState extends ScreenState<OnboardingDraft> {
  const OnboardingScreenState({
    super.data,
    super.error,
    super.phase,
    this.fieldErrors = const {},
    this.savedProfile,
  });

  const OnboardingScreenState.initial()
    : fieldErrors = const {},
      savedProfile = null,
      super(data: const OnboardingDraft(), phase: LoadPhase.idle);

  final Map<String, String> fieldErrors;
  final OnboardingProfile? savedProfile;

  @override
  OnboardingScreenState copyWith({
    OnboardingDraft? data,
    AppError? error,
    bool clearError = false,
    LoadPhase? phase,
    Map<String, String>? fieldErrors,
    OnboardingProfile? savedProfile,
    bool clearSavedProfile = false,
  }) {
    return OnboardingScreenState(
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
      phase: phase ?? this.phase,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      savedProfile: clearSavedProfile
          ? null
          : (savedProfile ?? this.savedProfile),
    );
  }
}
