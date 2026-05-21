import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Canonical user profile returned by the app backend.
@immutable
final class AppProfile {
  const AppProfile({
    required this.profileId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    required this.metadata,
    this.onboardingCompleted = false,
    this.onboardingCompletedAt,
  });

  final String profileId;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;

  /// Accepts either backend `profileId` or generic `id` fields.
  factory AppProfile.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return AppProfile(
      profileId: json['profileId'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: switch (created) {
        final String s =>
          DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0),
        final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
        _ => DateTime.fromMillisecondsSinceEpoch(0),
      },
      metadata: Map<String, dynamic>.from(
        (json['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      onboardingCompletedAt: switch (json['onboardingCompletedAt']) {
        final String s => DateTime.tryParse(s),
        final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
        _ => null,
      },
    );
  }

  Map<String, dynamic> toJson() => {
    'profileId': profileId,
    'email': email,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
    'onboardingCompleted': onboardingCompleted,
    'onboardingCompletedAt': onboardingCompletedAt?.toIso8601String(),
  };

  /// JSON string form used for local persistence.
  String toJsonString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProfile &&
          profileId == other.profileId &&
          email == other.email &&
          fullName == other.fullName &&
          avatarUrl == other.avatarUrl &&
          createdAt == other.createdAt &&
          mapEquals(metadata, other.metadata) &&
          onboardingCompleted == other.onboardingCompleted &&
          onboardingCompletedAt == other.onboardingCompletedAt;

  @override
  int get hashCode => Object.hash(
    profileId,
    email,
    fullName,
    avatarUrl,
    createdAt,
    Object.hashAll(metadata.entries),
    onboardingCompleted,
    onboardingCompletedAt,
  );
}
