import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/network/dio_client.dart';
import 'package:daily_record/core/utils/token_storage.dart';
import 'package:daily_record/core/models/login_request.dart';
import 'package:daily_record/core/models/login_response.dart';

class LoginService {
  final Dio _dio = DioClient.getInstance();

  Future<LoginResponse> login(
    LoginRequest request, {
    bool autoLogin = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toMap(),
      );
      final loginResponse = LoginResponse.fromMap(response.data['data']);
      await TokenStorage.saveTokens(
        accessToken: loginResponse.tokens.accessToken,
        refreshToken: loginResponse.tokens.refreshToken,
        expiresIn: loginResponse.tokens.expiresIn,
        autoLogin: autoLogin,
      );
      return loginResponse;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
