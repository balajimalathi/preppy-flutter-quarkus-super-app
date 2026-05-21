package com.preppy.user.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import java.util.Arrays;

public enum LearningMethod {
    READING("reading"),
    VISUAL("visual"),
    MCQ("mcq"),
    FLASHCARDS("flashcards"),
    VIDEOS("videos"),
    WRITING("writing");

    private final String value;

    LearningMethod(final String value) {
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
    public static LearningMethod fromValue(final String value) {
        return Arrays.stream(values())
                .filter(method -> method.value.equals(value))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Unsupported learning method: " + value));
    }
}
