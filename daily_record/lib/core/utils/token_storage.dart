import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey = 'expires_at';
  static const String _deviceIdKey = 'device_id';

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Save
  // In mobile enterprise flow, refresh token is the source of truth for auto login.
  // Access token is stored in memory only.
  // `expires_at` is a stored fallback expiration marker, but JWT exp is preferred.
  static Future<void> saveTokens({
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;

    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  // Get
  static Future<String?> getRefreshToken() async =>
      await _secureStorage.read(key: _refreshTokenKey);

  static Future<String?> getDeviceId() async =>
      await _secureStorage.read(key: _deviceIdKey);

  static Future<void> saveDeviceId(String deviceId) async {
    await _secureStorage.write(key: _deviceIdKey, value: deviceId);
  }

  static Future<bool> hasRefreshToken() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

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
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  // Clear ตอน logout
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
  }
}