package com.preppy.user.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import java.util.Arrays;

public enum GoalType {
    SUBJECT("subject"),
    COURSE("course"),
    COMPETITIVE_EXAM("competitive_exam"),
    PROFESSIONAL_CERT("professional_cert");

    private final String value;

    GoalType(final String value) {
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
    public static GoalType fromValue(final String value) {
        return Arrays.stream(values())
                .filter(type -> type.value.equals(value))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Unsupported goal type: " + value));
    }
}
