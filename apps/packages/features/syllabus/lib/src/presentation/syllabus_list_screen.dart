import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../application/state/syllabus_list_screen_state.dart';
import '../application/view_models/syllabus_list_view_model.dart';

class SyllabusListScreen extends ConsumerWidget {
  const SyllabusListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syllabusListViewModelProvider);

    return PreppyScaffold(
      title: 'Syllabus',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              ref.read(syllabusListViewModelProvider.notifier).refresh(),
        ),
      ],
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SyllabusListScreenState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasData) {
      return ErrorBody(
        error: state.error!,
        onRetry: () => ref.read(syllabusListViewModelProvider.notifier).load(),
      );
    }

    final items = state.data ?? const <SyllabusItem>[];

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No syllabus items yet.\n'
          'The API may return empty until TaxonomyService is implemented.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(syllabusListViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.code),
            leading: item.children.isNotEmpty
                ? const Icon(Icons.account_tree_outlined)
                : const Icon(Icons.article_outlined),
          );
        },
      ),
    );
  }
}
