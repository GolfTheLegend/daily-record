import 'package:daily_record/core/models/refresh_token_request.dart';
import 'package:daily_record/core/services/refresh_token_service.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioClient {
  static final _refreshService = RefreshTokenService();

  // ✅ navigatorKey สำหรับ redirect ไป login โดยไม่ต้องมี context
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Dio getInstance() {
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
          // ✅ ดักตอน 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefresh();

            if (refreshed) {
              // ✅ refresh สำเร็จ → retry request เดิมด้วย token ใหม่
              final newToken = await TokenStorage.getAccessToken();
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';

              try {
                final retryResponse = await dio.fetch(opts);
                return handler.resolve(retryResponse);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // ✅ refresh ล้มเหลว → logout → ไปหน้า Login
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

  // พยายาม refresh token
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

  // ล้าง token แล้วไปหน้า Login
  static Future<void> _forceLogout() async {
    await TokenStorage.clearTokens();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }
}
