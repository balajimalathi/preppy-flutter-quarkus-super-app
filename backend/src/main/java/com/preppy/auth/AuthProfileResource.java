package com.preppy.auth;

import com.preppy.auth.dto.ProfileResponse;
import com.preppy.user.UserService;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/v1/auth/profile")
@Produces(MediaType.APPLICATION_JSON)
public class AuthProfileResource {

    @Inject
    CurrentUser currentUser;

    @Inject
    UserService userService;

    @POST
    public ProfileResponse syncProfile() {
        return userService.syncFromFirebaseToken(currentUser.requireFirebaseToken());
    }

    @GET
    public ProfileResponse getProfile() {
        final UserPrincipal principal = currentUser.requirePrincipal();
        return userService.getByOriginAndExternalUid(principal.origin(), principal.externalUid());
    }
}
