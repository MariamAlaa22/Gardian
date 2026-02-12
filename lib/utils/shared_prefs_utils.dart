import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static SharedPreferences? _prefs;

  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // ميثود لحفظ قائمة من النصوص
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  // ميثود لاسترجاع قائمة من النصوص
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key, {String? defValue}) {
    return _prefs?.getString(key) ?? defValue;
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static double getDouble(String key, {double defValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defValue;
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  static int getInt(String key, {int defValue = 0}) {
    return _prefs?.getInt(key) ?? defValue;
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  static bool getBool(String key, {bool defValue = false}) {
    return _prefs?.getBool(key) ?? defValue;
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
}
