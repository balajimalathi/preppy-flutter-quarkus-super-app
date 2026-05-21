package com.preppy.user;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.Optional;
import java.util.UUID;

@ApplicationScoped
public class StudentProfileRepository implements PanacheRepositoryBase<StudentProfile, UUID> {

    public Optional<StudentProfile> findByUserId(final UUID userId) {
        return find("userId", userId).firstResultOptional();
    }
}
