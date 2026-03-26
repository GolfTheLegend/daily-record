import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/utils/token_storage.dart';

class DioClient {
  static Dio getInstance() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final expired = await TokenStorage.isAccessTokenExpired();
          if (expired) {
            // token หมดอายุ → ไปหน้า login
            // handle ตรงนี้ในขั้นต่อไป
          }

          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // handle 401, 500 ฯลฯ
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
