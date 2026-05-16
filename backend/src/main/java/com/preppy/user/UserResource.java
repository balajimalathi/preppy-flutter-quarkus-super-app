package com.preppy.user;

import com.preppy.auth.CurrentUser;
import com.preppy.auth.UserPrincipal;
import com.preppy.auth.dto.ProfileResponse;
import com.preppy.user.dto.UpdateFcmTokenRequest;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

/**
 * REST entry point for the authenticated user profile (exam, language, etc.).
 */
@Path("/v1/users")
@Produces(MediaType.APPLICATION_JSON)
public class UserResource {

    @Inject
    CurrentUser currentUser;

    @Inject
    UserService userService;

    @GET
    @Path("/me")
    public ProfileResponse me() {
        final UserPrincipal principal = currentUser.requirePrincipal();
        return userService.getOrSyncProfile(
                principal.origin(), principal.externalUid(), currentUser.requireFirebaseToken());
    }

    @PUT
    @Path("/me/fcm-token")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateFcmToken(final UpdateFcmTokenRequest body) {
        final UserPrincipal principal = currentUser.requirePrincipal();
        userService.updateFcmToken(
                principal.origin(),
                principal.externalUid(),
                body == null ? null : body.fcmToken(),
                currentUser.requireFirebaseToken());
        return Response.noContent().build();
    }
}
