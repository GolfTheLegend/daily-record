import 'package:daily_record/core/models/refresh_token_request.dart';
import 'package:daily_record/core/models/refresh_token_response.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/network/dio_client.dart';
import 'package:daily_record/core/utils/token_storage.dart';

class RefreshTokenService {
  final Dio _dio = DioClient.getInstance();

  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: request.toMap(),
      );
      final refreshTokenResponse = RefreshTokenResponse.fromMap(
        response.data['data'],
      );
      await TokenStorage.updateTokens(
        accessToken: refreshTokenResponse.accessToken,
        refreshToken: refreshTokenResponse.refreshToken,
        expiresIn: refreshTokenResponse.expiresIn,
      );
      return refreshTokenResponse;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
