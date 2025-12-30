import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';

class SessionService {
  static const _key = 'user_session';

  static Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  static Future<UserSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return UserSession.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}