package com.preppy.common.apilog;

import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public final class ApiLogSanitizer {

    private static final int MAX_BODY_CHARS = 8_192;

    private static final Set<String> REDACTED_HEADERS =
            Set.of("authorization", "cookie", "set-cookie", "x-api-key");

    private ApiLogSanitizer() {}

    public static Map<String, String> sanitizeHeaders(final Map<String, List<String>> headers) {
        final Map<String, String> sanitized = new LinkedHashMap<>();
        headers.forEach((name, values) -> {
            if (name == null) {
                return;
            }
            final String joined = values == null || values.isEmpty() ? "" : String.join(", ", values);
            sanitized.put(
                    name,
                    REDACTED_HEADERS.contains(name.toLowerCase(Locale.ROOT)) ? "[redacted]" : joined);
        });
        return sanitized;
    }

    public static boolean shouldCaptureBody(final String contentType) {
        if (contentType == null || contentType.isBlank()) {
            return true;
        }
        final String lower = contentType.toLowerCase(Locale.ROOT);
        if (lower.startsWith("multipart/")) {
            return false;
        }
        if (lower.startsWith("application/octet-stream")
                || lower.startsWith("image/")
                || lower.startsWith("video/")
                || lower.startsWith("audio/")) {
            return false;
        }
        return true;
    }

    public static String truncate(final String value) {
        if (value == null) {
            return null;
        }
        if (value.length() <= MAX_BODY_CHARS) {
            return value;
        }
        return value.substring(0, MAX_BODY_CHARS) + "...[truncated]";
    }

    public static String truncateBytes(final byte[] bytes) {
        if (bytes == null || bytes.length == 0) {
            return null;
        }
        if (bytes.length > MAX_BODY_CHARS) {
            return new String(bytes, 0, MAX_BODY_CHARS, StandardCharsets.UTF_8) + "...[truncated]";
        }
        return new String(bytes, StandardCharsets.UTF_8);
    }
}
