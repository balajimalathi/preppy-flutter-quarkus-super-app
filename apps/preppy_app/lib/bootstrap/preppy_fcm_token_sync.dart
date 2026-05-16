import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Registers the device FCM token with the Preppy API when the user is signed in.
class PreppyFcmTokenSync {
  PreppyFcmTokenSync._();

  static String? _pendingToken;
  static void Function()? _onTokenPendingSync;

  static const _path = '/v1/users/me/fcm-token';

  /// Set from [_FcmTokenSyncScope] to upload when a token arrives while signed in.
  static set onTokenPendingSync(void Function()? callback) {
    _onTokenPendingSync = callback;
  }

  /// Called from [CoreNotificationsCallbacks.onFcmToken].
  static void onTokenUpdated(String token) {
    if (token.isEmpty) {
      _pendingToken = null;
      return;
    }
    _pendingToken = token;
    _onTokenPendingSync?.call();
  }

  /// Uploads [_pendingToken] if Firebase Auth has a current user.
  static Future<void> trySync(Dio dio) async {
    final token = _pendingToken;
    if (token == null || token.isEmpty) {
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    try {
      await dio.put<void>(_path, data: <String, String?>{'fcmToken': token});
      developer.log('FCM token synced with backend', name: 'PreppyFCM');
    } catch (e, st) {
      developer.log(
        'FCM token sync failed',
        name: 'PreppyFCM',
        error: e,
        stackTrace: st,
      );
    }
  }
}
