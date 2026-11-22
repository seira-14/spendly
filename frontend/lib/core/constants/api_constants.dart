import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String _keyCustomHost = 'spendly_custom_server_host';
  static String? _cachedCustomHost;

  // Default IP for physical Android devices (Your PC Wi-Fi LAN IP)
  static const String defaultAndroidLanIp = '172.17.13.170';

  /// Load custom host from SharedPreferences on app start
  static Future<void> initHost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedCustomHost = prefs.getString(_keyCustomHost);
    } catch (_) {}
  }

  /// Save custom server IP/host (e.g. "172.17.13.170" or "http://172.17.13.170:8000/api")
  static Future<void> setCustomHost(String host) async {
    _cachedCustomHost = host.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomHost, _cachedCustomHost!);
  }

  /// Reset to default host
  static Future<void> resetCustomHost() async {
    _cachedCustomHost = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomHost);
  }

  static String? get customHost => _cachedCustomHost;

  // Base URLs
  static String get baseUrl {
    if (_cachedCustomHost != null && _cachedCustomHost!.isNotEmpty) {
      String host = _cachedCustomHost!;
      if (!host.startsWith('http://') && !host.startsWith('https://')) {
        host = 'http://$host';
      }
      if (!host.contains(':8000') && !host.contains('/api')) {
        host = '$host:8000/api';
      } else if (!host.endsWith('/api') && !host.endsWith('/api/')) {
        host = '$host/api';
      }
      return host.replaceAll(RegExp(r'/+$'), '');
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Automatically connects to your PC LAN IP on physical Android devices
        return 'http://$defaultAndroidLanIp:8000/api';
      default:
        return 'http://127.0.0.1:8000/api';
    }
  }

  // Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String firebaseSync = '/firebase-sync';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String avatar = '/user/avatar';
  static const String categories = '/categories';
  static const String expenses = '/expenses';
  static const String dashboard = '/dashboard';
  static const String reports = '/reports';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
