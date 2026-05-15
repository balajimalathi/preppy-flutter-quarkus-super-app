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
}
