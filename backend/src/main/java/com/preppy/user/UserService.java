package com.preppy.user;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

/**
 * Business logic for user profile management.
 */
@ApplicationScoped
public class UserService {

    @Inject
    UserRepository userRepository;

    public Object currentUser() {
        return null; // TODO: resolve from SecurityContext via UserPrincipal.
    }
}
