package com.preppy.auth;

import jakarta.annotation.Priority;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.container.PreMatching;
import jakarta.ws.rs.ext.Provider;

/**
 * JAX-RS request filter that validates the {@code Authorization: Bearer <ID_TOKEN>}
 * header against Firebase via the Admin SDK.
 *
 * <p>Scaffold stub — wire {@code FirebaseAuth.getInstance().verifyIdToken(token)}
 * here, build a {@link UserPrincipal} from the resulting {@code FirebaseToken} and
 * push it into the request's security context. Skip the {@code /q/*}, {@code /health}
 * and {@code /auth/*} paths.
 */
@Provider
@PreMatching
@Priority(Priorities.AUTHENTICATION)
public class AuthFilter implements ContainerRequestFilter {

    @Override
    public void filter(final ContainerRequestContext requestContext) {
        // TODO: extract bearer token, call FirebaseAuth.verifyIdToken, set SecurityContext.
    }
}
