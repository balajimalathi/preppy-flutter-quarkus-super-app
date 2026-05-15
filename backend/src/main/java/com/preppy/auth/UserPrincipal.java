package com.preppy.auth;

import com.preppy.user.AuthOrigin;
import java.security.Principal;
import java.util.Optional;
import java.util.UUID;

public record UserPrincipal(
        AuthOrigin origin, String externalUid, String email, String displayName, UUID userId)
        implements Principal {

    public UserPrincipal(
            final AuthOrigin origin, final String externalUid, final String email, final String displayName) {
        this(origin, externalUid, email, displayName, null);
    }

    @Override
    public String getName() {
        return externalUid;
    }

    public Optional<UUID> optionalUserId() {
        return Optional.ofNullable(userId);
    }

    public UserPrincipal withUserId(final UUID id) {
        return new UserPrincipal(origin, externalUid, email, displayName, id);
    }
}
