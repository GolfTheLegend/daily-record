import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/models/create_daily_record_request.dart';
import 'package:daily_record/core/models/create_daily_record_response.dart';
import 'package:daily_record/core/network/dio_client.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';

class CreateDailyRecordService {
  final Dio _dio = DioClient.getInstance();

  // POST /daily-records
  Future<CreateDailyRecordResponse> createDailyRecords(
    CreateDailyRecordsRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.createDailyRecord,
        data: request.toMap(),
      );
      return CreateDailyRecordResponse.fromMap(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
