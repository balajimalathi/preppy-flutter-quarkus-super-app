import 'package:core_models/core_models.dart';
import 'package:core_state/core_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/syllabus_providers.dart';
import '../state/syllabus_list_screen_state.dart';

class SyllabusListViewModel
    extends BaseViewModel<List<SyllabusItem>, SyllabusListScreenState> {
  @override
  SyllabusListScreenState initialState() =>
      const SyllabusListScreenState.initial();

  @override
  void initialize() => Future.microtask(load);

  Future<void> load() =>
      loadData(() => ref.read(getSyllabusTreeUseCaseProvider).execute());

  Future<void> refresh() =>
      refreshData(() => ref.read(getSyllabusTreeUseCaseProvider).execute());
}

final syllabusListViewModelProvider =
    NotifierProvider<SyllabusListViewModel, SyllabusListScreenState>(
      SyllabusListViewModel.new,
    );
