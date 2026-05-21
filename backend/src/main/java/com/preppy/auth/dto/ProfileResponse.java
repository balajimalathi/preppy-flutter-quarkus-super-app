package com.preppy.auth.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.preppy.user.dto.OnboardingProfileResponse;
import java.time.Instant;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ProfileResponse(
        String profileId,
        String email,
        String fullName,
        String avatarUrl,
        Instant createdAt,
        Map<String, Object> metadata,
        boolean onboardingCompleted,
        Instant onboardingCompletedAt,
        OnboardingProfileResponse onboardingProfile) {}
