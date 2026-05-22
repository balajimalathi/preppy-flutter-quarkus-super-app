import 'package:core_models/core_models.dart';

import '../../data/repositories/syllabus_repository.dart';

/// Loads the syllabus tree and maps repository failures to [AppError].
class GetSyllabusTreeUseCase {
  GetSyllabusTreeUseCase(this._repository);

  final SyllabusRepository _repository;

  Future<List<SyllabusItem>> execute() async {
    return (await _repository.fetchTree()).getOrThrow();
  }
}
