import 'package:dio/dio.dart';

import '../contracts/profile_contract.dart';
import '../models/app_profile.dart';
import 'profile_exceptions.dart';

final class QuarkusProfileService implements ProfileContract {
  QuarkusProfileService(this._dio);

  final Dio _dio;

  static const _path = '/v1/users/me';

  @override
  Future<AppProfile> syncProfile() => _fetch();

  @override
  Future<AppProfile> fetchProfile() => _fetch();

  Future<AppProfile> _fetch() async {
    try {
      final response = await _dio.get<dynamic>(_path);
      return _parse(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ProfileFetchException _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final serverMessage = _readServerMessage(e.response?.data);
    final baseUrl = e.requestOptions.baseUrl;

    final message = switch (status) {
      401 || 403 =>
        serverMessage ??
            'Server rejected your sign-in token. '
                'Ensure the API uses the same Firebase project as the app.',
      400 => serverMessage ?? 'Profile request was invalid',
      null when e.type == DioExceptionType.connectionError =>
        'Cannot reach API at $baseUrl. '
            'Start the backend and check BASE_URL (Android emulator: http://10.0.2.2:8080).',
      null
          when e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout =>
        'API request timed out ($baseUrl)',
      _ => serverMessage ?? e.message ?? 'Profile fetch failed',
    };

    return ProfileFetchException(message, cause: e, statusCode: status);
  }

  String? _readServerMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  AppProfile _parse(dynamic data) {
    if (data is! Map) {
      throw ProfileFetchException('Invalid profile response');
    }
    final map = data.cast<String, dynamic>();
    return AppProfile.fromJson(map);
  }
}
