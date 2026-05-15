import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/syllabus_repository_impl.dart';

final syllabusListProvider =
    NotifierProvider<SyllabusListNotifier, ApiResult<List<SyllabusItem>>>(
      SyllabusListNotifier.new,
    );

/// Loads the syllabus tree and exposes [ApiResult] for the list screen.
class SyllabusListNotifier extends Notifier<ApiResult<List<SyllabusItem>>> {
  @override
  ApiResult<List<SyllabusItem>> build() {
    Future.microtask(_load);
    return const ApiResult.idle();
  }

  Future<void> _load() async {
    state = ApiResult.loading(previousData: state.dataOrNull);
    try {
      final items = await ref.read(syllabusRepositoryProvider).fetchTree();
      state = ApiResult.success(items);
    } catch (e, st) {
      state = ApiResult.error(message: '$e', cause: st);
    }
  }

  Future<void> refresh() => _load();
}
