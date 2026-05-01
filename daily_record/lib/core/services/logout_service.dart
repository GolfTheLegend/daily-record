import 'package:daily_record/core/models/logout_all_request.dart';
import 'package:daily_record/core/models/logout_request.dart';
import 'package:daily_record/core/models/logout_response.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/network/dio_client.dart';

class LogoutService {
  final Dio _dio = DioClient.getInstance();

  Future<LogoutResponse> logout(LogoutRequest request) async {
    DioClient.beginLogout();
    try {
      final response = await _dio.post(
        ApiConstants.logout,
        data: request.toMap(),
      );
      return LogoutResponse.fromMap(
        response.data['data'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    } finally {
      DioClient.finishLogout();
    }
  }

  Future<LogoutResponse> logoutAll(LogoutAllRequest request) async {
    DioClient.beginLogout();
    try {
      final response = await _dio.post(
        ApiConstants.logoutAll,
        data: request.toMap(),
      );
      return LogoutResponse.fromMap(
        response.data['data'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    } finally {
      DioClient.finishLogout();
    }
  }
}
