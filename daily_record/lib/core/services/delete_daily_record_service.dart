import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/models/delete_daily_record_response.dart';
import 'package:daily_record/core/network/dio_client.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';

class DeleteDailyRecordService {
  final Dio _dio = DioClient.getInstance();

  // Delete /daily-records/:id
  Future<DeleteDailyRecordResponse> deleteDailyRecords(int id) async {
    try {
      final response = await _dio.delete(ApiConstants.dailyRecordById(id));

      return DeleteDailyRecordResponse.fromMap(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
