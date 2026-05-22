import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_syllabus_repository.dart';
import '../../data/repositories/syllabus_repository.dart';
import '../use_cases/get_syllabus_tree_use_case.dart';

final syllabusRepositoryProvider = Provider<SyllabusRepository>(
  ApiSyllabusRepository.new,
);

final getSyllabusTreeUseCaseProvider = Provider<GetSyllabusTreeUseCase>((ref) {
  return GetSyllabusTreeUseCase(ref.watch(syllabusRepositoryProvider));
});
