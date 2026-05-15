package com.preppy.auth;

import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.preppy.auth.firebase.FirebaseAuthService;
import com.preppy.user.AuthOrigin;
import io.quarkus.security.AuthenticationFailedException;
import io.quarkus.security.identity.SecurityIdentity;
import io.quarkus.security.runtime.QuarkusSecurityIdentity;
import io.quarkus.vertx.http.runtime.security.ChallengeData;
import io.quarkus.vertx.http.runtime.security.HttpAuthenticationMechanism;
import io.quarkus.vertx.http.runtime.security.HttpCredentialTransport;
import io.smallrye.mutiny.Uni;
import io.vertx.ext.web.RoutingContext;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.util.Set;
import org.jboss.logging.Logger;

/**
 * Verifies Firebase ID tokens when a Bearer credential is present. Does not enforce route access;
 * authorization is configured globally via {@code quarkus.http.auth.permission.*} in
 * application.properties.
 */
@ApplicationScoped
public class FirebaseAuthenticationMechanism implements HttpAuthenticationMechanism {

    private static final Logger LOG = Logger.getLogger(FirebaseAuthenticationMechanism.class);
    private static final String BEARER_PREFIX = "Bearer ";

    @Inject
    FirebaseAuthService firebaseAuthService;

    @Override
    public Uni<SecurityIdentity> authenticate(
            final RoutingContext context,
            final io.quarkus.security.identity.IdentityProviderManager identityProviderManager) {
        final String authorization = context.request().getHeader("Authorization");
        if (authorization == null || !authorization.startsWith(BEARER_PREFIX)) {
            return Uni.createFrom().nullItem();
        }

        final String token = authorization.substring(BEARER_PREFIX.length()).trim();
        if (token.isEmpty()) {
            return Uni.createFrom().nullItem();
        }

        return Uni.createFrom()
                .item(() -> {
                    try {
                        return buildIdentity(verifyToken(token));
                    } catch (final FirebaseAuthException e) {
                        LOG.debugf("Firebase token verification failed: %s", e.getMessage());
                        throw new AuthenticationFailedException("Missing or invalid Bearer token", e);
                    }
                });
    }

    private FirebaseToken verifyToken(final String token) throws FirebaseAuthException {
        return firebaseAuthService.verifyIdToken(token);
    }

    private SecurityIdentity buildIdentity(final FirebaseToken firebaseToken) {
        final UserPrincipal principal = new UserPrincipal(
                AuthOrigin.FIREBASE,
                firebaseToken.getUid(),
                firebaseToken.getEmail(),
                firebaseToken.getName());
        return QuarkusSecurityIdentity.builder()
                .setPrincipal(principal)
                .addRoles(Set.of("user"))
                .addAttribute(SecurityAttributes.AUTH_ORIGIN, AuthOrigin.FIREBASE)
                .addAttribute(SecurityAttributes.EXTERNAL_UID, firebaseToken.getUid())
                .addAttribute(SecurityAttributes.FIREBASE_TOKEN, firebaseToken)
                .build();
    }

    @Override
    public Uni<ChallengeData> getChallenge(final RoutingContext context) {
        return Uni.createFrom().item(new ChallengeData(401));
    }

    @Override
    public Set<Class<? extends io.quarkus.security.identity.request.AuthenticationRequest>> getCredentialTypes() {
        return Set.of();
    }

    @Override
    public Uni<HttpCredentialTransport> getCredentialTransport(final RoutingContext context) {
        return Uni.createFrom()
                .item(new HttpCredentialTransport(HttpCredentialTransport.Type.AUTHORIZATION, "bearer"));
    }
}
