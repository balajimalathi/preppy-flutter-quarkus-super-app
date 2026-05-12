package com.preppy.common;

import java.time.Instant;

/**
 * Generic envelope returned by every successful REST endpoint.
 *
 * @param <T> payload type
 */
public record ApiResponse<T>(T data, Instant timestamp) {

    public static <T> ApiResponse<T> of(final T data) {
        return new ApiResponse<>(data, Instant.now());
    }
}
