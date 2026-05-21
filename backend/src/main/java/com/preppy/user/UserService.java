package com.preppy.user;

import com.google.firebase.auth.FirebaseToken;
import com.preppy.auth.ProfileMapper;
import com.preppy.auth.dto.ProfileResponse;
import com.preppy.common.AppException;
import com.preppy.user.dto.OnboardingProfileResponse;
import com.preppy.user.dto.OnboardingUpsertRequest;
import com.preppy.user.model.LearningMethod;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.List;

@ApplicationScoped
public class UserService {

    @Inject
    UserRepository userRepository;

    @Inject
    StudentProfileRepository studentProfileRepository;

    @Inject
    LearningCapabilityProfileRepository learningCapabilityProfileRepository;

    @Inject
    NotificationPreferenceRepository notificationPreferenceRepository;

    @Transactional
    public ProfileResponse syncFromFirebaseToken(final FirebaseToken token) {
        final String externalUid = token.getUid();
        final String email = token.getEmail();
        if (email == null || email.isBlank()) {
            throw AppException.badRequest("Firebase token does not contain an email claim");
        }

        final String displayName = token.getName();
        final String picture = (String) token.getClaims().get("picture");

        User user = userRepository
                .findByOriginAndExternalUid(AuthOrigin.FIREBASE, externalUid)
                .orElse(null);
        final boolean isNew = user == null;
        if (isNew) {
            user = new User();
            user.setOrigin(AuthOrigin.FIREBASE.value());
            user.setExternalUid(externalUid);
        }

        user.setEmail(email);
        if (displayName != null && !displayName.isBlank()) {
            user.setDisplayName(displayName);
        }
        if (picture != null && !picture.isBlank()) {
            user.setAvatarUrl(picture);
        }

        if (isNew) {
            userRepository.persist(user);
            userRepository.getEntityManager().flush();
            user.setCreatedBy(user.getId());
        }
        user.setUpdatedBy(user.getId());

        userRepository.getEntityManager().flush();
        return toProfileResponse(user);
    }

    @Transactional
    public ProfileResponse getOrSyncProfile(
            final AuthOrigin origin, final String externalUid, final FirebaseToken token) {
        return userRepository
                .findByOriginAndExternalUid(origin, externalUid)
                .map(this::toProfileResponse)
                .orElseGet(() -> syncFromFirebaseToken(token));
    }

    @Transactional
    public void updateFcmToken(
            final AuthOrigin origin,
            final String externalUid,
            final String fcmToken,
            final FirebaseToken token) {
        User user = userRepository.findByOriginAndExternalUid(origin, externalUid).orElse(null);
        if (user == null) {
            syncFromFirebaseToken(token);
            user = userRepository
                    .findByOriginAndExternalUid(origin, externalUid)
                    .orElseThrow(() -> AppException.notFound("User profile not found"));
        }
        final String normalized = fcmToken == null ? null : fcmToken.trim();
        user.setFcmToken(normalized == null || normalized.isEmpty() ? null : normalized);
        user.setUpdatedBy(user.getId());
        userRepository.getEntityManager().flush();
    }

    @Transactional
    public OnboardingProfileResponse upsertOnboarding(
            final AuthOrigin origin,
            final String externalUid,
            final FirebaseToken token,
            final OnboardingUpsertRequest request) {
        if (request == null) {
            throw AppException.badRequest("Request validation failed", List.of("request: must not be null"));
        }
        validateQuietHours(request);

        User user = getOrCreateUser(origin, externalUid, token);

        final StudentProfile studentProfile = studentProfileRepository
                .findByUserId(user.getId())
                .orElseGet(() -> {
                    final StudentProfile profile = new StudentProfile();
                    profile.setUser(user);
                    return profile;
                });
        studentProfile.setLearningTarget(request.learningTarget().trim());
        studentProfile.setStudyLevel(request.studyLevel().value());
        studentProfile.setGoalType(request.goalType().value());
        studentProfile.setTargetDate(request.targetDate());
        if (studentProfile.getUserId() == null) {
            studentProfileRepository.persist(studentProfile);
        }

        final LearningCapabilityProfile capabilityProfile = learningCapabilityProfileRepository
                .findByUserId(user.getId())
                .orElseGet(() -> {
                    final LearningCapabilityProfile profile = new LearningCapabilityProfile();
                    profile.setUser(user);
                    return profile;
                });
        capabilityProfile.setDailyMinutes(request.dailyMinutes());
        capabilityProfile.setPreferredLearningMethods(request.preferredLearningMethods().stream()
                .map(LearningMethod::value)
                .toList());
        if (capabilityProfile.getUserId() == null) {
            learningCapabilityProfileRepository.persist(capabilityProfile);
        }

        final NotificationPreference notificationPreference = notificationPreferenceRepository
                .findByUserId(user.getId())
                .orElseGet(() -> {
                    final NotificationPreference preference = new NotificationPreference();
                    preference.setUser(user);
                    return preference;
                });
        notificationPreference.setNotificationsEnabled(request.notificationsEnabled());
        notificationPreference.setQuietHoursStart(request.quietHoursStart());
        notificationPreference.setQuietHoursEnd(request.quietHoursEnd());
        if (notificationPreference.getUserId() == null) {
            notificationPreferenceRepository.persist(notificationPreference);
        }

        if (user.getOnboardingCompletedAt() == null) {
            user.setOnboardingCompletedAt(Instant.now());
        }
        user.setUpdatedBy(user.getId());
        userRepository.getEntityManager().flush();

        return toOnboardingProfileResponse(user, studentProfile, capabilityProfile, notificationPreference);
    }

    private User getOrCreateUser(final AuthOrigin origin, final String externalUid, final FirebaseToken token) {
        return userRepository
                .findByOriginAndExternalUid(origin, externalUid)
                .orElseGet(() -> {
                    syncFromFirebaseToken(token);
                    return userRepository
                            .findByOriginAndExternalUid(origin, externalUid)
                            .orElseThrow(() -> AppException.notFound("User profile not found"));
                });
    }

    private ProfileResponse toProfileResponse(final User user) {
        final StudentProfile studentProfile = studentProfileRepository.findByUserId(user.getId()).orElse(null);
        final LearningCapabilityProfile capabilityProfile = learningCapabilityProfileRepository
                .findByUserId(user.getId())
                .orElse(null);
        final NotificationPreference notificationPreference = notificationPreferenceRepository
                .findByUserId(user.getId())
                .orElse(null);
        return ProfileMapper.toResponse(
                user,
                toOnboardingProfileResponse(user, studentProfile, capabilityProfile, notificationPreference));
    }

    private OnboardingProfileResponse toOnboardingProfileResponse(
            final User user,
            final StudentProfile studentProfile,
            final LearningCapabilityProfile capabilityProfile,
            final NotificationPreference notificationPreference) {
        if (studentProfile == null || capabilityProfile == null || notificationPreference == null) {
            return null;
        }
        return new OnboardingProfileResponse(
                user.getOnboardingCompletedAt() != null,
                user.getOnboardingCompletedAt(),
                studentProfile.getLearningTarget(),
                com.preppy.user.model.StudyLevel.fromValue(studentProfile.getStudyLevel()),
                com.preppy.user.model.GoalType.fromValue(studentProfile.getGoalType()),
                studentProfile.getTargetDate(),
                capabilityProfile.getDailyMinutes(),
                capabilityProfile.getPreferredLearningMethods().stream()
                        .map(LearningMethod::fromValue)
                        .toList(),
                notificationPreference.isNotificationsEnabled(),
                notificationPreference.getQuietHoursStart(),
                notificationPreference.getQuietHoursEnd());
    }

    private void validateQuietHours(final OnboardingUpsertRequest request) {
        final boolean hasStart = request.quietHoursStart() != null;
        final boolean hasEnd = request.quietHoursEnd() != null;
        if (hasStart != hasEnd) {
            throw AppException.badRequest(
                    "Invalid onboarding preference",
                    List.of("quietHoursStart: quiet hours start and end must be provided together"));
        }
        if (hasStart && request.quietHoursStart().equals(request.quietHoursEnd())) {
            throw AppException.badRequest(
                    "Invalid onboarding preference",
                    List.of("quietHoursStart: quiet hours start and end must be different"));
        }
    }
}
