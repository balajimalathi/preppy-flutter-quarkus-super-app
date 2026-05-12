package com.preppy.auth;

import java.security.Principal;

/**
 * JAX-RS {@link Principal} populated by {@link AuthFilter} from a verified
 * Firebase ID token. Carries the Firebase UID, email and (optional) display name.
 */
public record UserPrincipal(String firebaseUid, String email, String displayName) implements Principal {

    @Override
    public String getName() {
        return firebaseUid;
    }
}
