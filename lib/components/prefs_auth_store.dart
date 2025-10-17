import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsAuthStore extends AsyncAuthStore {
  static const _prefKey = 'pb_auth';

  PrefsAuthStore._({
    required Future<void> Function(String) saveFunc,
    String? initial,
    Future<void> Function()? clearFunc,
  }) : super(save: saveFunc, initial: initial, clear: clearFunc);

  static Future<PrefsAuthStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    final initial = prefs.getString(_prefKey);

    Future<void> saveFunc(String serialized) async {
      await prefs.setString(_prefKey, serialized);
    }

    Future<void> clearFunc() async {
      await prefs.remove(_prefKey);
    }

    return PrefsAuthStore._(
      saveFunc: saveFunc,
      initial: initial,
      clearFunc: clearFunc,
    );
  }
}
