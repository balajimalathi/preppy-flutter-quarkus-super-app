import 'package:core_models/core_models.dart';
import 'package:core_network/core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/entities/onboarding_profile.dart';
import '../mappers/onboarding_mapper.dart';
import 'onboarding_repository.dart';

final class ApiOnboardingRepository
    with OnboardingMapper, DioAware
    implements OnboardingRepository {
  ApiOnboardingRepository(this.ref);

  @override
  final Ref ref;

  static const _path = '/v1/users/me/onboarding';

  @override
  Future<Result<OnboardingProfile>> upsertOnboarding(
    OnboardingDraft draft,
  ) async {
    final result = await dioPutEnvelope(
      dio: dio,
      path: _path,
      data: draftToJson(draft),
      fromJson: profileFromJson,
    );
    return result.when(
      success: Result.success,
      onFailure: (failure) => Result.failure(_mapValidationFailure(failure)),
    );
  }

  Failure _mapValidationFailure(Failure failure) {
    if (failure is! NetworkFailure || failure.code != 400) {
      return failure;
    }
    final data = failure.cause;
    if (data is! Map) {
      return failure;
    }
    final fieldErrors = _readFieldErrors(data['errors']);
    if (fieldErrors.isEmpty) {
      return failure;
    }
    return UnknownFailure(
      message: 'validation',
      code: 400,
      cause: ValidationError(fieldErrors),
    );
  }

  Map<String, String> _readFieldErrors(Object? rawErrors) {
    if (rawErrors is! List) {
      return const {};
    }
    final result = <String, String>{};
    for (final raw in rawErrors.whereType<String>()) {
      final split = raw.indexOf(':');
      if (split <= 0) {
        continue;
      }
      result[raw.substring(0, split).trim()] = raw.substring(split + 1).trim();
    }
    return result;
  }
}
