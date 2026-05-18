/// Node in a syllabus tree.
class SyllabusItem {
  const SyllabusItem({
    required this.id,
    required this.code,
    required this.title,
    this.parentId,
    this.children = const [],
  });

  /// Stable identifier for the syllabus node.
  final String id;

  /// Parent node id for flat-tree representations, if any.
  final String? parentId;

  /// Short curriculum code or sequence label.
  final String code;

  /// Human-readable title for the syllabus node.
  final String title;

  /// Nested child syllabus items.
  final List<SyllabusItem> children;
}
