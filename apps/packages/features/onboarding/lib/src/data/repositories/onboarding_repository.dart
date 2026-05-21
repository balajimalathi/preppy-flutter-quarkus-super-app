import 'package:core_models/core_models.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/entities/onboarding_profile.dart';

abstract interface class OnboardingRepository {
  Future<Result<OnboardingProfile>> upsertOnboarding(OnboardingDraft draft);
}
