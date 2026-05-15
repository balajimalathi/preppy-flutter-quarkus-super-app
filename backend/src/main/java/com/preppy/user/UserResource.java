package com.preppy.user;

import com.preppy.auth.CurrentUser;
import com.preppy.auth.dto.ProfileResponse;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * REST entry point for the authenticated user profile (exam, language, etc.).
 */
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
public class UserResource {

    @Inject
    CurrentUser currentUser;

    @Inject
    UserService userService;

    @GET
    @Path("/me")
    public ProfileResponse me() {
        return userService.getByUserId(currentUser.requireUserId());
    }
}
