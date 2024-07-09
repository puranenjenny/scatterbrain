import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    if (!_prefs!.containsKey('selectedMorningTime')) {
      await _prefs!.setString('selectedMorningTime', '10:00');
    }
    if (!_prefs!.containsKey('selectedEveningTime')) {
      await _prefs!.setString('selectedEveningTime', '22:00');
    }
    if (!_prefs!.containsKey('selectedFrequency')) {
      await _prefs!.setString('selectedFrequency', '10');
    }
    if (!_prefs!.containsKey('dailyResetTime')) {
      await _prefs!.setString('dailyResetTime', '05:00');
    }
    if (!_prefs!.containsKey('notificationsEnabled')) {
      await _prefs!.setBool('notificationsEnabled', true);
    }

  }

  static bool getBool(String key, {bool defaultValue = false}) {
    bool value = _prefs?.getBool(key) ?? defaultValue;
    print("Getting $key: $value");
    return value;
  }

  static Future<bool> setBool(String key, bool value) async {
    print("Setting $key to $value");
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }

  static Future<bool> setString(String key, String value) async {
    print('Saving $key with value $value');
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  static String getString(String key, {String defaultValue = ''}) {
    String value = _prefs?.getString(key) ?? defaultValue;
    print('Loading $key with value $value');
    return value;
  }
}