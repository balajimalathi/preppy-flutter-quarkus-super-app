import 'package:core_models/core_models.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
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
    try {
      final response = await dio.put<Map<String, dynamic>>(
        _path,
        data: draftToJson(draft),
      );
      final body = response.data;
      final data = body?['data'];
      if (data is! Map<String, dynamic>) {
        return const Result.failure(
          NetworkFailure(message: 'Invalid onboarding response'),
        );
      }
      return Result.success(profileFromJson(data));
    } on DioException catch (error, stackTrace) {
      return Result.failure(_failureFromDio(error, stackTrace));
    } catch (error, stackTrace) {
      return Result.failure(
        UnknownFailure(message: error.toString(), cause: stackTrace),
      );
    }
  }

  Failure _failureFromDio(DioException error, StackTrace stackTrace) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (statusCode == 400 && data is Map) {
      final fieldErrors = _readFieldErrors(data['errors']);
      if (fieldErrors.isNotEmpty) {
        return UnknownFailure(
          message: 'validation',
          code: 400,
          cause: ValidationError(fieldErrors),
        );
      }
    }
    return NetworkFailure(
      message: _readMessage(data) ?? error.message ?? 'Onboarding save failed',
      code: statusCode,
      cause: stackTrace,
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

  String? _readMessage(Object? data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
