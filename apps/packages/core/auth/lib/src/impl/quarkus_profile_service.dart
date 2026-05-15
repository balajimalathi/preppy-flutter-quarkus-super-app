import 'package:dio/dio.dart';

import '../contracts/profile_contract.dart';
import '../models/app_profile.dart';
import 'profile_exceptions.dart';

final class QuarkusProfileService implements ProfileContract {
  QuarkusProfileService(this._dio);

  final Dio _dio;

  static const _path = '/users/me';

  @override
  Future<AppProfile> syncProfile() => _fetch();

  @override
  Future<AppProfile> fetchProfile() => _fetch();

  Future<AppProfile> _fetch() async {
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
