import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _darkModeKey = 'dark_mode';
  static const String _lastWifiNameKey = 'last_wifi_name';
  static const String _lastWifiPasswordKey = 'last_wifi_password';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<String> getLastWifiName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastWifiNameKey) ?? '';
  }

  Future<String> getLastWifiPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastWifiPasswordKey) ?? '';
  }

  Future<void> saveLastCredentials(String name, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWifiNameKey, name);
    await prefs.setString(_lastWifiPasswordKey, password);
  }
}
