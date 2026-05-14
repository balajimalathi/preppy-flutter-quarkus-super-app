// Placeholder options — run `flutterfire configure` per Firebase project and flavor.
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for the **prod** Firebase project / Android flavor.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured for prod; run flutterfire configure.',
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
    apiKey: 'AIzaSyDa5XppPIzbYztTjU7IYFGQcoSnUzo-Ut0',
    appId: '1:222654864742:android:1cfe6e3680284f9e1a7ca7',
    messagingSenderId: '222654864742',
    projectId: 'hlp-chat',
    storageBucket: 'hlp-chat.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAaB0Y3Or2KgMhNZ-NIkZOS78s5TAnPhng',
    appId: '1:222654864742:ios:545a1730ab77d0151a7ca7',
    messagingSenderId: '222654864742',
    projectId: 'hlp-chat',
    storageBucket: 'hlp-chat.firebasestorage.app',
    iosBundleId: 'com.skndan.preppyapp',
  );
}
