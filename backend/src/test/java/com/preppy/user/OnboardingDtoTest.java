package com.preppy.user;

import static org.junit.jupiter.api.Assertions.assertTrue;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.preppy.user.dto.OnboardingProfileResponse;
import com.preppy.user.dto.OnboardingUpsertRequest;
import com.preppy.user.model.GoalType;
import com.preppy.user.model.LearningMethod;
import com.preppy.user.model.StudyLevel;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.validation.Validator;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import org.junit.jupiter.api.Test;

@QuarkusTest
class OnboardingDtoTest {

    @Inject
    ObjectMapper objectMapper;

    @Inject
    Validator validator;

    @Test
    void requestSerializesLowercaseEnums() throws Exception {
        final var request = new OnboardingUpsertRequest(
                "JEE Physics",
                StudyLevel.COMPETITIVE_EXAM,
                GoalType.COMPETITIVE_EXAM,
                LocalDate.of(2026, 12, 31),
                90,
                List.of(LearningMethod.MCQ, LearningMethod.FLASHCARDS),
                true,
                LocalTime.of(22, 0),
                LocalTime.of(6, 0));

        final String json = objectMapper.writeValueAsString(request);

        assertTrue(json.contains("\"studyLevel\":\"competitive_exam\""), json);
        assertTrue(json.contains("\"goalType\":\"competitive_exam\""), json);
        assertTrue(json.contains("\"preferredLearningMethods\":[\"mcq\",\"flashcards\"]"), json);
    }

    @Test
    void responseSerializesOnboardingFields() throws Exception {
        final var response = new OnboardingProfileResponse(
                true,
                Instant.parse("2026-05-19T10:00:00Z"),
                "Data Structures",
                StudyLevel.UNDERGRADUATE,
                GoalType.COURSE,
                LocalDate.of(2026, 8, 1),
                45,
                List.of(LearningMethod.READING),
                false,
                null,
                null);

        final String json = objectMapper.writeValueAsString(response);

        assertTrue(json.contains("\"onboardingCompleted\":true"), json);
        assertTrue(json.contains("\"learningTarget\":\"Data Structures\""), json);
        assertTrue(json.contains("\"dailyMinutes\":45"), json);
    }

    @Test
    void requestValidationRejectsMissingRequiredFields() {
        final var request = new OnboardingUpsertRequest(
                "",
                null,
                null,
                null,
                4,
                List.of(),
                false,
                null,
                null);

        final var paths = validator.validate(request).stream()
                .map(violation -> violation.getPropertyPath().toString())
                .toList();

        assertTrue(paths.contains("learningTarget"), paths.toString());
        assertTrue(paths.contains("studyLevel"), paths.toString());
        assertTrue(paths.contains("goalType"), paths.toString());
        assertTrue(paths.contains("targetDate"), paths.toString());
        assertTrue(paths.contains("dailyMinutes"), paths.toString());
        assertTrue(paths.contains("preferredLearningMethods"), paths.toString());
    }
}
