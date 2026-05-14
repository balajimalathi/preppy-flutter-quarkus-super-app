import 'package:core_analytics/core_analytics.dart';
import 'package:core_env/core_env.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../app.dart';
import '../env/app_env_firebase.dart';

/// Shared startup: storage, Firebase, Riverpod overrides, then [runApp].
Future<void> bootstrap(AppEnv env) async {
  if (env.baseUrl.isEmpty) {
    throw StateError(
      'Missing compile-time defines (BASE_URL). '
      'Run via Melos, e.g. `melos run run:dev`, or pass '
      '`--dart-define-from-file=config/env.dev.json` when invoking Flutter.',
    );
  }

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: env.firebaseOptionsFor(env.environment),
  );

  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
    env.analyticsEnabled,
  );
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    env.crashlyticsEnabled,
  );

  await SharedPreferencesSingleton.init();
  await Hive.initFlutter();

  runApp(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(env),
        baseUrlProvider.overrideWithValue(env.baseUrl),
      ],
      child: const PreppyApp(),
    ),
  );
}
