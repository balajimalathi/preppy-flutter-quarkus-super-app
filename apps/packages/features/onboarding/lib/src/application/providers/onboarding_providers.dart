import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_onboarding_repository.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../use_cases/save_onboarding_use_case.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  ApiOnboardingRepository.new,
);

final saveOnboardingUseCaseProvider = Provider<SaveOnboardingUseCase>((ref) {
  return SaveOnboardingUseCase(ref.watch(onboardingRepositoryProvider));
});
