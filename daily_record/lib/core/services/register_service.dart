import 'package:daily_record/core/models/register_request.dart';
import 'package:daily_record/core/models/register_response.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/network/dio_client.dart';

class RegisterService {
  final Dio _dio = DioClient.getInstance();

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: request.toMap(),
      );
      final registerResponse = RegisterResponse.fromMap(response.data['data']);
      return registerResponse;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
