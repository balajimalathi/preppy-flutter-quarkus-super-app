import 'package:core_models/core_models.dart';

/// Port for syllabus tree CRUD against the Quarkus taxonomy API.
abstract interface class SyllabusRepository {
  Future<List<SyllabusItem>> fetchTree();

  Future<SyllabusItem> fetchById(String id);

  Future<SyllabusItem> create(SyllabusItem draft);

  Future<SyllabusItem> update(SyllabusItem item);

  Future<void> delete(String id);
}
