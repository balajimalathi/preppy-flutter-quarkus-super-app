import 'package:core_models/core_models.dart';

/// Syllabus tree access against the taxonomy API.
abstract interface class SyllabusRepository {
  Future<Result<List<SyllabusItem>>> fetchTree();
}
