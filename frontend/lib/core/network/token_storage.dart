import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyToken = 'spendly_auth_token';
  static const String _keyShowBalance = 'spendly_show_balance';
  static const String _keyLastEmail = 'spendly_last_email';

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Save Auth Token securely
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
    }
  }

  /// Retrieve Auth Token
  static Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _keyToken);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Remove Auth Token on logout
  static Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _keyToken);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  /// Save balance visibility toggle state
  static Future<void> setBalanceVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowBalance, isVisible);
  }

  /// Get balance visibility toggle state (default true)
  static Future<bool> getBalanceVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowBalance) ?? true;
  }

  /// Save last remembered email for convenience
  static Future<void> saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastEmail, email);
  }

  static Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastEmail);
  }
}
