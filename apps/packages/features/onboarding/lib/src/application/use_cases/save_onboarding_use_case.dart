import 'package:core_models/core_models.dart';

import '../../data/repositories/onboarding_repository.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../../domain/entities/onboarding_profile.dart';

class SaveOnboardingUseCase {
  SaveOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<OnboardingProfile> execute(OnboardingDraft draft) async {
    final result = await _repository.upsertOnboarding(draft);
    if (result case FailureResult(:final failure)
        when failure.cause is ValidationError) {
      throw failure.cause! as ValidationError;
    }
    return result.getOrThrow();
  }
}
