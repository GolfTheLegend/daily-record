import 'package:daily_record/core/models/logout_request.dart';
import 'package:daily_record/core/models/logout_response.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/network/dio_client.dart';

class LogoutService {
  final Dio _dio = DioClient.getInstance();

  Future<LogoutResponse> logout(LogoutRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.logout,
        data: request.toMap(),
      );
      final logoutResponse = LogoutResponse.fromMap(response.data['data']);
      return logoutResponse;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
