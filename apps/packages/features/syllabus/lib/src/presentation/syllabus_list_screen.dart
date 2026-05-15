import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/shared_ui.dart';

import '../application/syllabus_list_notifier.dart';

class SyllabusListScreen extends ConsumerWidget {
  const SyllabusListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syllabusListProvider);

    return PreppyScaffold(
      title: 'Syllabus',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(syllabusListProvider.notifier).refresh(),
        ),
      ],
      body: state.when(
        idle: () => const Center(child: Text('Loading syllabus…')),
        loading: (_) => const Center(child: CircularProgressIndicator()),
        success: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No syllabus items yet.\n'
                'The API may return empty until TaxonomyService is implemented.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
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
          );
        },
        error: (msg, _, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(msg, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
