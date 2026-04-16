import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/models/check_list_request.dart';
import 'package:daily_record/core/models/check_list_response.dart';
import 'package:daily_record/core/network/dio_client.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';

class UpdateCheckListService {
  final Dio _dio = DioClient.getInstance();

  // POST /daily-records
  Future<CheckListResponse> updateCheckLists(
    int id,
    CheckListRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkListRecord(id),
        data: request.toMap(),
      );
      return CheckListResponse.fromMap(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
