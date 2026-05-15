package com.preppy.auth;

import com.preppy.user.UserRepository;
import io.quarkus.security.identity.AuthenticationRequestContext;
import io.quarkus.security.identity.SecurityIdentity;
import io.quarkus.security.identity.SecurityIdentityAugmentor;
import io.quarkus.security.runtime.QuarkusSecurityIdentity;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.util.UUID;

@ApplicationScoped
public class UserIdentityAugmentor implements SecurityIdentityAugmentor {

    @Inject
    UserRepository userRepository;

    @Override
    public Uni<SecurityIdentity> augment(
            final SecurityIdentity identity, final AuthenticationRequestContext context) {
        if (identity.isAnonymous() || !(identity.getPrincipal() instanceof UserPrincipal principal)) {
            return Uni.createFrom().item(identity);
        }

        return Uni.createFrom()
                .item(() -> userRepository.findByOriginAndExternalUid(
                        principal.origin(), principal.externalUid()))
                .map(optionalUser -> {
                    if (optionalUser.isEmpty()) {
                        return identity;
                    }
                    final UUID userId = optionalUser.get().getId();
                    final UserPrincipal augmented = principal.withUserId(userId);
                    return QuarkusSecurityIdentity.builder(identity)
                            .setPrincipal(augmented)
                            .addAttribute(SecurityAttributes.USER_ID, userId)
                            .build();
                });
    }
}
