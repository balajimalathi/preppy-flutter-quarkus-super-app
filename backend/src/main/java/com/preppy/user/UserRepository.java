package com.preppy.user;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Panache-backed access for the {@code users} table. Will become a
 * {@code PanacheRepositoryBase<UserEntity, UUID>} once entities are introduced.
 */
@ApplicationScoped
public class UserRepository {
}
