import 'package:core_models/core_models.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/syllabus_repository.dart';
import '../mappers/syllabus_mapper.dart';

final syllabusRepositoryProvider = Provider<SyllabusRepository>((ref) {
  return SyllabusRepositoryImpl(ref.watch(dioProvider));
});

class SyllabusRepositoryImpl with SyllabusMapper implements SyllabusRepository {
  SyllabusRepositoryImpl(this._dio);

  final Dio _dio;

  static const _basePath = '/taxonomy/syllabus';

  @override
  Future<List<SyllabusItem>> fetchTree() async {
    final response = await _dio.get<dynamic>(_basePath);
    final data = response.data;
    if (data == null) return [];
    if (data is List) {
      return data
          .map((e) => syllabusItemFromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      return [syllabusItemFromJson(data)];
    }
    return [];
  }

  @override
  Future<SyllabusItem> fetchById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('$_basePath/$id');
    return syllabusItemFromJson(response.data!);
  }

  @override
  Future<SyllabusItem> create(SyllabusItem draft) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _basePath,
      data: syllabusItemToJson(draft),
    );
    return syllabusItemFromJson(response.data!);
  }

  @override
  Future<SyllabusItem> update(SyllabusItem item) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '$_basePath/${item.id}',
      data: syllabusItemToJson(item),
    );
    return syllabusItemFromJson(response.data!);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('$_basePath/$id');
  }
}
