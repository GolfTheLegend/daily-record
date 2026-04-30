import 'package:daily_record/core/models/refresh_token_request.dart';
import 'package:daily_record/core/services/refresh_token_service.dart';
import 'package:daily_record/core/utils/auth_event_bus.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum _RefreshStatus { success, invalidToken, networkIssue }

class DioClient {
  // ✅ Singleton — สร้างครั้งเดียว
  static Dio? _instance;
  
  // ✅ Dio แยกต่างหากสำหรับ refresh (ไม่มี interceptor)
  static final Dio _refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  
  static late final RefreshTokenService _refreshService =
      RefreshTokenService(dio: _refreshDio); // inject dio แยก

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ✅ In-memory access token cache
  static String? _cachedAccessToken;

  static const Duration _refreshTimeout = Duration(seconds: 10);
  static const int _maxRefreshAttempts = 2;

  // ✅ ป้องกัน refresh ซ้อนกัน
  static bool _isRefreshing = false;
  static Future<_RefreshStatus>? _refreshFuture;

  static Stream<AuthEvent> get authEvents => AuthEventBus.stream;

  static Dio getInstance() {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },

        onError: (error, handler) async {
          if (error.requestOptions.extra['retry'] == true) {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            final requestPath = error.requestOptions.path;
            if (requestPath == ApiConstants.refreshToken) {
              await _forceLogout();
              return handler.next(error);
            }

            // ✅ ถ้ากำลัง refresh อยู่แล้ว รอผลเดิม (ไม่ refresh ซ้ำ)
            if (_isRefreshing) {
              _refreshFuture ??= Future.value(_RefreshStatus.networkIssue);
              final status = await _refreshFuture!;
              if (status == _RefreshStatus.success) {
                return _retryRequest(dio, error, handler);
              }
              if (status == _RefreshStatus.invalidToken) {
                await _forceLogout();
              }
              return handler.next(error);
            }

            _isRefreshing = true;
            _refreshFuture = _tryRefresh();

            final status = await _refreshFuture!;
            _isRefreshing = false;
            _refreshFuture = null;

            if (status == _RefreshStatus.success) {
              return _retryRequest(dio, error, handler);
            }
            if (status == _RefreshStatus.invalidToken) {
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

  static Future<void> _retryRequest(
    Dio dio,
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      if (error.requestOptions.method != 'GET') {
        return handler.next(error);
      }

      final newToken = await _getAccessToken();
      final opts = error.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      opts.extra['retry'] = true;
      final retryResponse = await dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (e) {
      return handler.next(error);
    }
  }

  static Future<String?> _getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await TokenStorage.getAccessToken();
    return _cachedAccessToken;
  }

  static void _setAccessToken(String token) {
    _cachedAccessToken = token;
  }

  static Future<void> initAuthState() async {
    _cachedAccessToken = await TokenStorage.getAccessToken();
  }

  static Future<bool> tryRefreshDirect() async {
    if (_isRefreshing) {
      final status = await _refreshFuture ?? _RefreshStatus.networkIssue;
      return status == _RefreshStatus.success;
    }

    _isRefreshing = true;
    _refreshFuture = _tryRefresh();

    final status = await _refreshFuture!;
    _isRefreshing = false;
    _refreshFuture = null;

    return status == _RefreshStatus.success;
  }

  static Future<_RefreshStatus> _tryRefresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      return _RefreshStatus.invalidToken;
    }

    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        final response = await _refreshService
            .refreshToken(RefreshTokenRequest(refreshToken: refreshToken))
            .timeout(_refreshTimeout);

        await TokenStorage.updateTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          expiresIn: response.expiresIn,
        );
        _setAccessToken(response.accessToken);
        return _RefreshStatus.success;
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          return _RefreshStatus.invalidToken;
        }

        if (attempt >= _maxRefreshAttempts) {
          return _RefreshStatus.networkIssue;
        }

        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e, st) {
        debugPrint('Refresh token failed: $e');
        debugPrint('$st');

        if (attempt >= _maxRefreshAttempts) {
          return _RefreshStatus.networkIssue;
        }

        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
  }

  static Future<void> _forceLogout() async {
    await TokenStorage.clearTokens();
    AuthEventBus.emitLogout();
  }
}