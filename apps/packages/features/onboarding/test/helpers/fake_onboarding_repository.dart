import 'package:core_models/core_models.dart';
import 'package:onboarding/src/data/repositories/onboarding_repository.dart';
import 'package:onboarding/src/domain/entities/onboarding_draft.dart';
import 'package:onboarding/src/domain/entities/onboarding_profile.dart';

final class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({
    this.result = const Result.failure(UnknownFailure(message: 'unset')),
    this.onUpsert,
  });

  final Result<OnboardingProfile> result;
  final Future<Result<OnboardingProfile>> Function(OnboardingDraft draft)?
  onUpsert;
  int calls = 0;
  OnboardingDraft? lastDraft;

  @override
  Future<Result<OnboardingProfile>> upsertOnboarding(
    OnboardingDraft draft,
  ) async {
    calls++;
    lastDraft = draft;
    final handler = onUpsert;
    if (handler != null) {
      return handler(draft);
    }
    return result;
  }
}
