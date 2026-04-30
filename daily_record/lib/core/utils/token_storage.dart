import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const String _accessTokenKey  = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey    = 'expires_at';

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Save
  // In mobile enterprise flow, refresh token is the source of truth for auto login.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;

    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  // Get
  static Future<String?> getAccessToken() async =>
      await _secureStorage.read(key: _accessTokenKey);

  static Future<String?> getRefreshToken() async =>
      await _secureStorage.read(key: _refreshTokenKey);
  // เช็คว่า token หมดอายุหรือยัง
  static Future<bool> isAccessTokenExpired({Duration buffer = const Duration(minutes: 2)}) async {
    final expiresAtString = await _secureStorage.read(key: _expiresAtKey);
    if (expiresAtString == null) return true;

    final expiresAt = int.tryParse(expiresAtString);
    if (expiresAt == null) return true;

    return DateTime.now().millisecondsSinceEpoch + buffer.inMilliseconds >= expiresAt;
  }

  //update
  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  // Clear ตอน logout
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
  }
}