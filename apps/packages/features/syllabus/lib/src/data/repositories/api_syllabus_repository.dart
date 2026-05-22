import 'package:core_models/core_models.dart';
import 'package:core_network/core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mappers/syllabus_mapper.dart';
import 'syllabus_repository.dart';

/// Loads the syllabus tree from `/taxonomy/syllabus`.
final class ApiSyllabusRepository
    with SyllabusMapper, DioAware
    implements SyllabusRepository {
  ApiSyllabusRepository(this.ref);

  @override
  final Ref ref;

  static const _path = '/taxonomy/syllabus';

  @override
  Future<Result<List<SyllabusItem>>> fetchTree() =>
      dioGetList(dio: dio, path: _path, fromJson: syllabusItemFromJson);
}
