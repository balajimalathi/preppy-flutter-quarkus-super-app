import 'package:core_models/core_models.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../mappers/dashboard_summary_mapper.dart';
import 'dashboard_remote_data_source.dart';

final class DashboardRemoteDataSourceImpl
    with DashboardSummaryMapper
    implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const _path = '/dashboard/summary';

  @override
  Future<Result<DashboardSummary>> fetchSummary() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_path);
      final body = response.data;
      if (body == null) {
        return const Result.failure(
          NetworkFailure(message: 'Empty dashboard summary response'),
        );
      }
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        return const Result.failure(
          NetworkFailure(message: 'Invalid dashboard summary envelope'),
        );
      }
      return Result.success(summaryFromJson(data));
    } on DioException catch (e, st) {
      return Result.failure(
        NetworkFailure(
          message: e.message ?? 'Network request failed',
          code: e.response?.statusCode,
          cause: st,
        ),
      );
    } catch (e, st) {
      return Result.failure(UnknownFailure(message: e.toString(), cause: st));
    }
  }
}
