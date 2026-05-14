// Placeholder options — run `flutterfire configure` per Firebase project and flavor.
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for the **staging** Firebase project / Android flavor.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured for staging; run flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyStgPlaceholderReplaceWithFlutterFire',
    appId: '1:100001000002:android:stg0000000000001',
    messagingSenderId: '100001000002',
    projectId: 'preppy-staging',
    storageBucket: 'preppy-staging.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyStgPlaceholderReplaceWithFlutterFire',
    appId: '1:100001000002:ios:stg00000000000001',
    messagingSenderId: '100001000002',
    projectId: 'preppy-staging',
    storageBucket: 'preppy-staging.firebasestorage.app',
    iosBundleId: 'com.skndan.preppyApp.staging',
  );
}
