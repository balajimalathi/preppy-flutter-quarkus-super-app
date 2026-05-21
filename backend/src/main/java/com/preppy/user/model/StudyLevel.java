package com.preppy.user.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import java.util.Arrays;

public enum StudyLevel {
    SCHOOL("school"),
    UNDERGRADUATE("undergraduate"),
    POSTGRADUATE("postgraduate"),
    COMPETITIVE_EXAM("competitive_exam"),
    PROFESSIONAL("professional");

    private final String value;

    StudyLevel(final String value) {
        this.value = value;
    }

    @JsonValue
    public String value() {
        return value;
    }

    @Override
    public String toString() {
        return value;
    }

    @JsonCreator
    public static StudyLevel fromValue(final String value) {
        return Arrays.stream(values())
                .filter(level -> level.value.equals(value))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Unsupported study level: " + value));
    }
}
