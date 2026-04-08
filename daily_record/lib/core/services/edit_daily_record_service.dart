import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/models/daily_record_request.dart';
import 'package:daily_record/core/models/edit_daily_record_response.dart';
import 'package:daily_record/core/network/dio_client.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';

class UpdateDailyRecordService {
  final Dio _dio = DioClient.getInstance();

  // PUT /daily-records/{id}
  Future<EditDailyRecordResponse> updateDailyRecords(
    int id,
    DailyRecordsRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.dailyRecordById(id),
        data: request.toMap(),
      );

      return EditDailyRecordResponse.fromMap(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
