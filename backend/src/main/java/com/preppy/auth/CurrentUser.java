package com.preppy.auth;

import com.google.firebase.auth.FirebaseToken;
import com.preppy.common.AppException;
import com.preppy.user.User;
import com.preppy.user.UserRepository;
import io.quarkus.security.identity.SecurityIdentity;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import java.util.UUID;

@RequestScoped
public class CurrentUser {

    @Inject
    SecurityIdentity securityIdentity;

    @Inject
    UserRepository userRepository;

    public UserPrincipal requirePrincipal() {
        if (securityIdentity.isAnonymous()
                || !(securityIdentity.getPrincipal() instanceof UserPrincipal principal)) {
            throw AppException.unauthorized("Authentication required");
        }
        return principal;
    }

    public FirebaseToken requireFirebaseToken() {
        final FirebaseToken token =
                securityIdentity.getAttribute(SecurityAttributes.FIREBASE_TOKEN);
        if (token == null) {
            throw AppException.unauthorized("Firebase token not available on security context");
        }
        return token;
    }

    public UUID requireUserId() {
        final UUID userId = securityIdentity.getAttribute(SecurityAttributes.USER_ID);
        if (userId != null) {
            return userId;
        }
        return requirePrincipal()
                .optionalUserId()
                .orElseThrow(() -> AppException.notFound(
                        "User profile has not been synced yet; call POST /v1/auth/profile first"));
    }

    public User requireUser() {
        return userRepository
                .findByIdOptional(requireUserId())
                .orElseThrow(() -> AppException.notFound("User not found for authenticated session"));
    }
}
