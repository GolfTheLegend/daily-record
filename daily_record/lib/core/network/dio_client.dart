import 'dart:async';
import 'dart:convert';

import 'package:daily_record/core/models/refresh_token_request.dart';
import 'package:daily_record/core/services/device_service.dart';
import 'package:daily_record/core/services/refresh_token_service.dart';
import 'package:daily_record/core/utils/auth_event_bus.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/core/config/app_config.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum RefreshStatus { success, invalidToken, networkIssue }

class DioClient {
  // ✅ Singleton — สร้างครั้งเดียว
  static Dio? _instance;

  // ✅ Dio แยกต่างหากสำหรับ refresh (ไม่มี interceptor)
  static final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: AppConfig.instance.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static late final RefreshTokenService _refreshService = RefreshTokenService(
    dio: _refreshDio,
  ); // inject dio แยก

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ✅ In-memory access token cache
  static String? _cachedAccessToken;

  static const Duration _refreshTimeout = Duration(seconds: 10);
  static const Duration _refreshGracePeriod = Duration(seconds: 30);
  static const int _maxRefreshAttempts = 3;

  // ✅ ป้องกัน refresh ซ้อนกัน และให้ request อื่นรอผล
  static bool _isRefreshing = false;
  static Future<RefreshStatus>? _refreshFuture;

  // ✅ ป้องกัน request ใหม่ระหว่าง logout
  static bool _isLoggingOut = false;

  static const _publicPaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.refreshToken,
  };

  static Stream<AuthEvent> get authEvents => AuthEventBus.stream;

  static Dio getInstance() {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_publicPaths.contains(options.path)) {
            return handler.next(options);
          }
          if (_isLoggingOut &&
              options.path != ApiConstants.logout &&
              options.path != ApiConstants.logoutAll) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Request blocked during logout',
                response: Response(requestOptions: options, statusCode: 409),
              ),
            );
          }

          String? token;

          if (options.path != ApiConstants.refreshToken) {
            final hasRefreshToken = await TokenStorage.hasRefreshToken();
            final currentToken = await _getAccessToken();
            final needsRefresh =
                hasRefreshToken &&
                _isAccessTokenExpiredOrExpiringSoon(currentToken);

            if (needsRefresh) {
              final status = await _refreshLockAndRefresh();
              if (status == RefreshStatus.invalidToken) {
                await _forceLogout();
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    error: 'Authentication expired',
                    response: Response(
                      requestOptions: options,
                      statusCode: 401,
                    ),
                  ),
                );
              }

              if (status == RefreshStatus.networkIssue) {
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    error: 'Unable to refresh expired access token',
                    response: Response(
                      requestOptions: options,
                      statusCode: 503,
                    ),
                  ),
                );
              }

              token = await _getAccessToken();
            } else {
              token = currentToken;
            }
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },

        onError: (error, handler) async {
          if (error.requestOptions.extra['retry'] == true) {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            // ✅ 1. helper method — ชัดเจน อ่านง่าย
            if (!_shouldAttemptRefresh(error.requestOptions)) {
              return handler.next(error);
            }

            // ✅ 2. เช็ค refresh token ก่อน — กันเคส user ยังไม่ login
            final hasRefreshToken = await TokenStorage.hasRefreshToken();
            if (!hasRefreshToken) {
              return handler.next(error);
            }

            if (_isRefreshing) {
              final status = await _refreshFuture ?? RefreshStatus.networkIssue;
              if (status == RefreshStatus.success) {
                return _retryRequest(dio, error, handler);
              }
              if (status == RefreshStatus.invalidToken) {
                await _forceLogout();
              }
              return handler.next(error);
            }

            _isRefreshing = true;
            _refreshFuture = _tryRefresh();
            final status = await _refreshFuture!;
            _isRefreshing = false;
            _refreshFuture = null;

            if (status == RefreshStatus.success) {
              return _retryRequest(dio, error, handler);
            }
            if (status == RefreshStatus.invalidToken) {
              await _forceLogout();
            }
            return handler.next(error);
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static bool _shouldAttemptRefresh(RequestOptions request) {
    if (_publicPaths.contains(request.path)) return false;
    if (request.path == ApiConstants.refreshToken) return false;
    return true;
  }

  static Future<void> _retryRequest(
    Dio dio,
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final newToken = await _getAccessToken();
      final opts = error.requestOptions;
      if (newToken != null && newToken.isNotEmpty) {
        opts.headers['Authorization'] = 'Bearer $newToken';
      }
      opts.extra['retry'] = true;
      final retryResponse = await dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (e) {
      return handler.next(error);
    }
  }

  static Future<String?> _getAccessToken() async {
    return _cachedAccessToken;
  }

  static void setAccessToken(String token) {
    _cachedAccessToken = token;
  }

  static void clearAccessToken() {
    _cachedAccessToken = null;
  }

  static Future<bool> hasValidAccessToken() async {
    final token = await _getAccessToken();
    if (token == null || token.isEmpty) return false;
    return !_isAccessTokenExpiredOrExpiringSoon(token);
  }

  static Future<void> initAuthState() async {
    _cachedAccessToken = null;
    _isLoggingOut = false;
    _isRefreshing = false;
    _refreshFuture = null;
  }

  static Future<RefreshStatus> tryRefreshDirect() async {
    final status = await _refreshLockAndRefresh();
    return status;
  }

  static Future<RefreshStatus> _refreshLockAndRefresh() async {
    if (_isRefreshing) {
      return await _refreshFuture ?? RefreshStatus.networkIssue;
    }

    _isRefreshing = true;
    _refreshFuture = _tryRefresh();
    final status = await _refreshFuture!;
    _isRefreshing = false;
    _refreshFuture = null;
    return status;
  }

  static Future<RefreshStatus> _tryRefresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return RefreshStatus.invalidToken;
    }

    final deviceId = await DeviceService.getDeviceId();
    for (var attempt = 1; attempt <= _maxRefreshAttempts; attempt += 1) {
      try {
        final response = await _refreshService
            .refreshToken(
              RefreshTokenRequest(
                refreshToken: refreshToken,
                deviceId: deviceId,
              ),
            )
            .timeout(_refreshTimeout);

        await TokenStorage.updateTokens(
          refreshToken: response.refreshToken,
          expiresIn: response.expiresIn,
        );
        setAccessToken(response.accessToken);
        return RefreshStatus.success;
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          return RefreshStatus.invalidToken;
        }

        if (attempt >= _maxRefreshAttempts) {
          return RefreshStatus.networkIssue;
        }

        final backoffSeconds = 1 << (attempt - 1);
        await Future.delayed(Duration(seconds: backoffSeconds));
      } catch (e, st) {
        assert(() {
          debugPrint('Refresh token failed: $e');
          debugPrint('$st');
          return true;
        }());

        if (attempt >= _maxRefreshAttempts) {
          return RefreshStatus.networkIssue;
        }

        final backoffSeconds = 1 << (attempt - 1);
        await Future.delayed(Duration(seconds: backoffSeconds));
      }
    }

    return RefreshStatus.networkIssue;
  }

  static bool _isAccessTokenExpiredOrExpiringSoon(String? token) {
    if (token == null || token.isEmpty) {
      return true;
    }

    final expiry = _decodeJwtExpiry(token);
    if (expiry == null) {
      return true;
    }

    return DateTime.now().toUtc().add(_refreshGracePeriod).isAfter(expiry);
  }

  static DateTime? _decodeJwtExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      }
      if (exp is String) {
        final expInt = int.tryParse(exp);
        if (expInt != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            expInt * 1000,
            isUtc: true,
          );
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<void> _forceLogout() async {
    await TokenStorage.clearTokens();
    _cachedAccessToken = null;
    AuthEventBus.emitLogout();
  }

  static void beginLogout() {
    _isLoggingOut = true;
  }

  static void finishLogout() {
    _isLoggingOut = false;
  }
}
