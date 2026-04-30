import 'package:daily_record/core/models/refresh_token_request.dart';
import 'package:daily_record/core/models/refresh_token_response.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';

class RefreshTokenService {
  final Dio _dio;

  // ✅ รับ Dio จากภายนอก ไม่สร้างเอง
  RefreshTokenService({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: request.toMap(),
      );
      return RefreshTokenResponse.fromMap(
        response.data['data'],
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
