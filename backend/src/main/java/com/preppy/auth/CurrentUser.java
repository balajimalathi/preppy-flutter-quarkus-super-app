package com.preppy.auth;

import com.google.firebase.auth.FirebaseToken;
import com.preppy.common.AppException;
import io.quarkus.security.identity.SecurityIdentity;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;

@RequestScoped
public class CurrentUser {

    @Inject
    SecurityIdentity securityIdentity;

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
}
