// Placeholder options — run `flutterfire configure` per Firebase project and flavor.
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for the **dev** Firebase project / Android flavor.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured for dev; run flutterfire configure.',
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
    apiKey: 'AIzaSyDevPlaceholderReplaceWithFlutterFire',
    appId: '1:100001000001:android:dev0000000000001',
    messagingSenderId: '100001000001',
    projectId: 'preppy-dev',
    storageBucket: 'preppy-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDevPlaceholderReplaceWithFlutterFire',
    appId: '1:100001000001:ios:dev00000000000001',
    messagingSenderId: '100001000001',
    projectId: 'preppy-dev',
    storageBucket: 'preppy-dev.firebasestorage.app',
    iosBundleId: 'com.skndan.preppyApp.dev',
  );
}
