import 'package:dio/dio.dart';

import '../contracts/profile_contract.dart';
import '../models/app_profile.dart';
import 'profile_exceptions.dart';

final class QuarkusProfileService implements ProfileContract {
  QuarkusProfileService(this._dio);

  final Dio _dio;

  static const _path = '/v1/auth/profile';

  @override
  Future<AppProfile> syncProfile() async {
    try {
      final response = await _dio.post<dynamic>(_path);
      return _parse(response.data);
    } on DioException catch (e) {
      throw ProfileSyncException(e.message ?? 'Profile sync failed', cause: e);
    }
  }

  @override
  Future<AppProfile> fetchProfile() async {
    try {
      final response = await _dio.get<dynamic>(_path);
      return _parse(response.data);
    } on DioException catch (e) {
      throw ProfileFetchException(
        e.message ?? 'Profile fetch failed',
        cause: e,
      );
    }
  }

  AppProfile _parse(dynamic data) {
    if (data is! Map) {
      throw ProfileFetchException('Invalid profile response');
    }
    final map = data.cast<String, dynamic>();
    return AppProfile.fromJson(map);
  }
}
