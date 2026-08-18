import 'package:shared_preferences/shared_preferences.dart';

class RememberMeStorage {
  static const String _rememberKey = 'remember_me_enabled';
  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';

  static Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!rememberMe) {
      await clearCredentials();
      return;
    }

    await prefs.setBool(_rememberKey, true);
    await prefs.setString(_emailKey, email.trim());
    await prefs.setString(_passwordKey, password);
  }

  static Future<Map<String, String?>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_rememberKey) ?? false)) {
      return {'email': null, 'password': null};
    }

    return {
      'email': prefs.getString(_emailKey),
      'password': prefs.getString(_passwordKey),
    };
  }

  static Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberKey) ?? false;
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }
}
