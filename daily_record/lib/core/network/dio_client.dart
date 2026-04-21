import 'package:daily_record/core/models/refresh_token_request.dart';
import 'package:daily_record/core/services/refresh_token_service.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioClient {
  // ✅ Singleton — สร้างครั้งเดียว
  static Dio? _instance;
  
  // ✅ Dio แยกต่างหากสำหรับ refresh (ไม่มี interceptor)
  static final Dio _refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  
  static late final RefreshTokenService _refreshService =
      RefreshTokenService(dio: _refreshDio); // inject dio แยก

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ✅ ป้องกัน refresh ซ้อนกัน
  static bool _isRefreshing = false;
  static Future<bool>? _refreshFuture;

  static Dio getInstance() {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },

        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // ✅ ถ้ากำลัง refresh อยู่แล้ว รอผลเดิม (ไม่ refresh ซ้ำ)
            if (_isRefreshing) {
              _refreshFuture ??= Future.value(false);
              final refreshed = await _refreshFuture!;
              if (refreshed) {
                return _retryRequest(dio, error, handler);
              }
              await _forceLogout();
              return handler.next(error);
            }

            _isRefreshing = true;
            _refreshFuture = _tryRefresh();

            final refreshed = await _refreshFuture!;
            _isRefreshing = false;
            _refreshFuture = null;

            if (refreshed) {
              return _retryRequest(dio, error, handler);
            } else {
              await _forceLogout();
              return handler.next(error);
            }
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
      final newToken = await TokenStorage.getAccessToken();
      final opts = error.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (e) {
      return handler.next(error);
    }
  }

  static Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      await _refreshService.refreshToken(
        RefreshTokenRequest(refreshToken: refreshToken),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _forceLogout() async {
    await TokenStorage.clearTokens();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }
}