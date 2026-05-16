package com.preppy.user.dto;

/**
 * Body for {@code PUT /v1/users/me/fcm-token}.
 */
public record UpdateFcmTokenRequest(String fcmToken) {}
