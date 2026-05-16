package com.preppy.user;

import com.google.firebase.auth.FirebaseToken;
import com.preppy.auth.ProfileMapper;
import com.preppy.auth.dto.ProfileResponse;
import com.preppy.common.AppException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class UserService {

    @Inject
    UserRepository userRepository;

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
        return ProfileMapper.toResponse(user);
    }

    @Transactional
    public ProfileResponse getOrSyncProfile(
            final AuthOrigin origin, final String externalUid, final FirebaseToken token) {
        return userRepository
                .findByOriginAndExternalUid(origin, externalUid)
                .map(ProfileMapper::toResponse)
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
}
