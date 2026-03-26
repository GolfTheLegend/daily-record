import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey  = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey    = 'expires_at';

  // Save
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn, // seconds
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
    await prefs.setString(_accessTokenKey,  accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_expiresAtKey,       expiresAt);
  }

  // Get
  static Future<String?> getAccessToken()  async => (await SharedPreferences.getInstance()).getString(_accessTokenKey);
  static Future<String?> getRefreshToken() async => (await SharedPreferences.getInstance()).getString(_refreshTokenKey);

  // เช็คว่า token หมดอายุหรือยัง
  static Future<bool> isAccessTokenExpired() async {
    final prefs     = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt(_expiresAtKey);
    if (expiresAt == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= expiresAt;
  }

  // Clear ตอน logout
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_expiresAtKey);
  }
}