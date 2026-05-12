package com.preppy.common;

import java.util.List;

/**
 * Cursor-less page wrapper. Use this for endpoints that page by {@code page}/{@code size}.
 */
public record PagedResponse<T>(List<T> items, long total, int page, int size) {

    public static <T> PagedResponse<T> of(final List<T> items, final long total, final int page, final int size) {
        return new PagedResponse<>(items, total, page, size);
    }
}
