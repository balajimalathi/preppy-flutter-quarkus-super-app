import 'package:core_env/core_env.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase/dev/firebase_options.dart' as dev_fb;
import '../firebase/prod/firebase_options.dart' as prod_fb;
import '../firebase/staging/firebase_options.dart' as staging_fb;

extension AppEnvFirebase on AppEnv {
  /// Picks generated [FirebaseOptions] for the active [Environment].
  FirebaseOptions firebaseOptionsFor(Environment env) {
    return switch (env) {
      DevEnvironment() => dev_fb.DefaultFirebaseOptions.currentPlatform,
      StagingEnvironment() => staging_fb.DefaultFirebaseOptions.currentPlatform,
      ProdEnvironment() => prod_fb.DefaultFirebaseOptions.currentPlatform,
    };
  }
}
