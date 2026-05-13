class SyllabusItem {
  const SyllabusItem({
    required this.id,
    required this.code,
    required this.title,
    this.parentId,
    this.children = const [],
  });

  final String id;
  final String? parentId;
  final String code;
  final String title;
  final List<SyllabusItem> children;
}
