package com.preppy.user.dto;

import com.preppy.user.model.GoalType;
import com.preppy.user.model.LearningMethod;
import com.preppy.user.model.StudyLevel;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public record OnboardingUpsertRequest(
        @NotBlank @Size(max = 200) String learningTarget,
        @NotNull StudyLevel studyLevel,
        @NotNull GoalType goalType,
        @NotNull @FutureOrPresent LocalDate targetDate,
        @Min(5) @Max(480) int dailyMinutes,
        @NotEmpty List<LearningMethod> preferredLearningMethods,
        boolean notificationsEnabled,
        LocalTime quietHoursStart,
        LocalTime quietHoursEnd) {}
