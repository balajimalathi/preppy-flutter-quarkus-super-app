package com.preppy.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ErrorResponse(String message, List<String> errors) {

    public static ErrorResponse of(final String message) {
        return new ErrorResponse(message, null);
    }

    public static ErrorResponse of(final String message, final List<String> errors) {
        return new ErrorResponse(message, errors);
    }
}
