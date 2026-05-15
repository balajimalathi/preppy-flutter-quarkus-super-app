package com.preppy.auth;

import com.preppy.auth.dto.ProfileResponse;
import com.preppy.user.User;
import java.util.Map;

public final class ProfileMapper {

    private ProfileMapper() {}

    public static ProfileResponse toResponse(final User user) {
        return new ProfileResponse(
                user.getId().toString(),
                user.getEmail(),
                user.getDisplayName(),
                user.getAvatarUrl(),
                user.getCreatedAt(),
                Map.of());
    }
}
