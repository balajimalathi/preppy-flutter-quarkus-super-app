package com.preppy.auth;

import com.preppy.user.AuthOrigin;
import java.security.Principal;

public record UserPrincipal(AuthOrigin origin, String externalUid, String email, String displayName)
        implements Principal {

    @Override
    public String getName() {
        return externalUid;
    }
}
