import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setBool(String key, bool value) async {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static Future<bool> setString(String key, String value) async {
      return _prefs?.setString(key, value) ?? Future.value(false);
    }

  static String getString(String key, {String defaultValue = ''}) {
      return _prefs?.getString(key) ?? defaultValue;
    }

}