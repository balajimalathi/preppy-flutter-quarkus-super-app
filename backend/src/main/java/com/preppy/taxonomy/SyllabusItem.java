package com.preppy.taxonomy;

import java.util.List;
import java.util.UUID;

/**
 * Single node in the syllabus tree. Self-referential through {@link #children}.
 */
public record SyllabusItem(UUID id, UUID parentId, String code, String title, List<SyllabusItem> children) {
}
