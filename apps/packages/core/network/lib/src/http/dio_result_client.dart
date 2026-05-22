import 'package:core_models/core_models.dart';
import 'package:dio/dio.dart';

import '../connectivity/connectivity_contract.dart';
import '../connectivity/connectivity_state.dart';

/// GET [path] and parse the JSON envelope (`{ "data": { ... } }` by default).
Future<Result<T>> dioGetEnvelope<T>({
  required Dio dio,
  required String path,
  required T Function(Map<String, dynamic> json) fromJson,
  String envelopeKey = 'data',
  Map<String, dynamic>? queryParameters,
  Options? options,
}) async {
  try {
    final response = await dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    final body = response.data;
    if (body == null) {
      return const Result.failure(
        NetworkFailure(message: 'Empty response body'),
      );
    }
    final data = body[envelopeKey];
    if (data is! Map<String, dynamic>) {
      return Result.failure(
        NetworkFailure(
          message:
              'Invalid response envelope: missing or invalid "$envelopeKey"',
        ),
      );
    }
    return Result.success(fromJson(data));
  } on DioException catch (e, st) {
    return Result.failure(_networkFailureFromDio(e, st));
  } catch (e, st) {
    return Result.failure(UnknownFailure(message: e.toString(), cause: st));
  }
}

/// PUT [path] and parse the JSON envelope (`{ "data": { ... } }` by default).
Future<Result<T>> dioPutEnvelope<T>({
  required Dio dio,
  required String path,
  required T Function(Map<String, dynamic> json) fromJson,
  Object? data,
  String envelopeKey = 'data',
  Options? options,
}) async {
  try {
    final response = await dio.put<Map<String, dynamic>>(
      path,
      data: data,
      options: options,
    );
    final body = response.data;
    if (body == null) {
      return const Result.failure(
        NetworkFailure(message: 'Empty response body'),
      );
    }
    final parsed = body[envelopeKey];
    if (parsed is! Map<String, dynamic>) {
      return Result.failure(
        NetworkFailure(
          message:
              'Invalid response envelope: missing or invalid "$envelopeKey"',
        ),
      );
    }
    return Result.success(fromJson(parsed));
  } on DioException catch (e, st) {
    return Result.failure(_networkFailureFromDio(e, st));
  } catch (e, st) {
    return Result.failure(UnknownFailure(message: e.toString(), cause: st));
  }
}

/// GET [path] and parse a JSON list (raw array or `{ "data": [ ... ] }`).
Future<Result<List<T>>> dioGetList<T>({
  required Dio dio,
  required String path,
  required T Function(Map<String, dynamic> json) fromJson,
  String envelopeKey = 'data',
  Map<String, dynamic>? queryParameters,
  Options? options,
}) async {
  try {
    final response = await dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    return Result.success(
      _parseJsonList(
        response.data,
        fromJson: fromJson,
        envelopeKey: envelopeKey,
      ),
    );
  } on DioException catch (e, st) {
    return Result.failure(_networkFailureFromDio(e, st));
  } catch (e, st) {
    return Result.failure(UnknownFailure(message: e.toString(), cause: st));
  }
}

NetworkFailure _networkFailureFromDio(
  DioException error,
  StackTrace stackTrace,
) {
  final responseData = error.response?.data;
  return NetworkFailure(
    message: error.message ?? 'Network request failed',
    code: error.response?.statusCode,
    cause: responseData ?? stackTrace,
  );
}

List<T> _parseJsonList<T>(
  dynamic data, {
  required T Function(Map<String, dynamic> json) fromJson,
  required String envelopeKey,
}) {
  if (data == null) {
    return [];
  }
  if (data is List) {
    return data
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  if (data is Map<String, dynamic>) {
    final nested = data[envelopeKey];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [fromJson(data)];
  }
  return [];
}

/// Offline: return cache or [CacheFailure]. Online: remote fetch and persist on success.
Future<Result<T>> fetchWithOfflineCache<T>({
  required ConnectivityContract connectivity,
  required Future<T?> Function() getCached,
  required Future<void> Function(T data) saveCached,
  required Future<Result<T>> Function() fetchRemote,
  String emptyCacheMessage = 'No cached data available',
}) async {
  final status = await connectivity.currentStatus;
  if (status == ConnectivityState.offline) {
    final cached = await getCached();
    if (cached != null) {
      return Result.success(cached);
    }
    return Result.failure(CacheFailure(message: emptyCacheMessage));
  }

  final remote = await fetchRemote();
  if (remote case Success(:final data)) {
    await saveCached(data);
  }
  return remote;
}
