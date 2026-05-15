package com.preppy.user;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.Optional;
import java.util.UUID;

@ApplicationScoped
public class UserRepository implements PanacheRepositoryBase<User, UUID> {

    public Optional<User> findByOriginAndExternalUid(final AuthOrigin origin, final String externalUid) {
        return find("origin = ?1 and externalUid = ?2", origin.value(), externalUid).firstResultOptional();
    }
}
