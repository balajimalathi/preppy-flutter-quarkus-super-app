import 'package:core_storage/core_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesSingleton.init();
  await Hive.initFlutter();

  runApp(const ProviderScope(child: PreppyApp()));
}
