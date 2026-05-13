import 'package:shared_preferences/shared_preferences.dart';

/// Eager [SharedPreferences] holder so sync code (e.g. Riverpod [Provider]s)
/// can access the same instance after [init] completes in `main()`.
final class SharedPreferencesSingleton {
  SharedPreferencesSingleton._();

  static SharedPreferences? _prefs;

  /// Call once from `main()` after [WidgetsFlutterBinding.ensureInitialized].
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPreferences not initialized. Call '
        'SharedPreferencesSingleton.init() from main() after '
        'WidgetsFlutterBinding.ensureInitialized().',
      );
    }
    return prefs;
  }
}
