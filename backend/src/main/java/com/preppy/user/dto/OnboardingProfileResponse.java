package com.preppy.user.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.preppy.user.model.GoalType;
import com.preppy.user.model.LearningMethod;
import com.preppy.user.model.StudyLevel;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record OnboardingProfileResponse(
        boolean onboardingCompleted,
        Instant onboardingCompletedAt,
        String learningTarget,
        StudyLevel studyLevel,
        GoalType goalType,
        LocalDate targetDate,
        int dailyMinutes,
        List<LearningMethod> preferredLearningMethods,
        boolean notificationsEnabled,
        LocalTime quietHoursStart,
        LocalTime quietHoursEnd) {}
