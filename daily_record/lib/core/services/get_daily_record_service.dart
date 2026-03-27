import 'package:daily_record/core/models/get_daily_record_request.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/network/dio_client.dart';

class GetDailyRecordService {
  final Dio _dio = DioClient.getInstance();

  // GET /daily-records/:id
  Future<DailyRecordItem> getDailyRecord(int id) async {
    try {
      final response = await _dio.get(ApiConstants.dailyRecordById(id));
      return DailyRecordItem.fromMap(response.data['data']);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  // GET /daily-records
  Future<GetDailyRecordsResponse> getDailyRecords(
    GetDailyRecordsRequest request,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.dailyRecords,
        queryParameters: request.toMap(),
      );
      return GetDailyRecordsResponse.fromMap(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
