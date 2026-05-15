import 'package:core_models/core_models.dart';

/// JSON ↔ [SyllabusItem]. Lives in the data layer so [core_models] stays pure.
mixin SyllabusMapper {
  SyllabusItem syllabusItemFromJson(Map<String, dynamic> json) {
    return SyllabusItem(
      id: '${json['id']}',
      code: json['code'] as String,
      title: json['title'] as String,
      parentId: json['parentId'] != null ? '${json['parentId']}' : null,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => syllabusItemFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> syllabusItemToJson(SyllabusItem item) => {
    'id': item.id,
    'code': item.code,
    'title': item.title,
    if (item.parentId != null) 'parentId': item.parentId,
    'children': item.children.map(syllabusItemToJson).toList(),
  };
}
