import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
final class AppProfile {
  const AppProfile({
    required this.profileId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    required this.metadata,
  });

  final String profileId;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

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
    );
  }

  Map<String, dynamic> toJson() => {
    'profileId': profileId,
    'email': email,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

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
          mapEquals(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    profileId,
    email,
    fullName,
    avatarUrl,
    createdAt,
    Object.hashAll(metadata.entries),
  );
}
