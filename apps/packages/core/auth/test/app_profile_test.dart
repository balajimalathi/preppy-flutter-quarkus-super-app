import 'dart:convert';

import 'package:core_auth/core_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_fakes.dart';

void main() {
  group('AppProfile', () {
    test('fromJson reads profileId and ISO createdAt', () {
      final profile = AppProfile.fromJson({
        'profileId': 'p1',
        'email': 'a@b.com',
        'fullName': 'Alice',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'metadata': {'k': 'v'},
      });
      expect(profile.profileId, 'p1');
      expect(profile.email, 'a@b.com');
      expect(profile.fullName, 'Alice');
      expect(profile.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(profile.metadata, {'k': 'v'});
    });

    test('fromJson falls back to id when profileId missing', () {
      final profile = AppProfile.fromJson({
        'id': 'legacy-id',
        'email': 'x@y.com',
        'createdAt': 1_700_000_000_000,
      });
      expect(profile.profileId, 'legacy-id');
      expect(
        profile.createdAt,
        DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000),
      );
    });

    test('fromJson uses empty metadata when missing', () {
      final profile = AppProfile.fromJson({
        'profileId': 'p',
        'email': 'e@e.com',
        'createdAt': 'invalid',
      });
      expect(profile.metadata, isEmpty);
      expect(profile.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('toJson and toJsonString round-trip', () {
      final profile = sampleProfile;
      final decoded = AppProfile.fromJson(
        jsonDecode(profile.toJsonString()) as Map<String, dynamic>,
      );
      expect(decoded, profile);
    });

    test('equality and hashCode', () {
      final a = sampleProfile;
      final b = AppProfile(
        profileId: 'profile-1',
        email: 'user@example.com',
        fullName: 'Test User',
        createdAt: sampleProfile.createdAt,
        metadata: const {'role': 'student'},
      );
      final c = AppProfile(
        profileId: 'other',
        email: 'user@example.com',
        fullName: 'Test User',
        createdAt: sampleProfile.createdAt,
        metadata: const {'role': 'student'},
      );
      expect(a, b);
      expect(a == c, isFalse);
    });
  });
}
