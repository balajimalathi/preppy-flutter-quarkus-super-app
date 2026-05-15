package com.preppy.user;

/**
 * Identity provider that issued the user's external UID.
 */
public enum AuthOrigin {
    FIREBASE,
    SUPABASE;

    public String value() {
        return name().toLowerCase();
    }

    public static AuthOrigin fromValue(final String value) {
        return AuthOrigin.valueOf(value.toUpperCase());
    }
}
