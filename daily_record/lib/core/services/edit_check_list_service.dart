import 'package:daily_record/core/constants/api_constants.dart';
import 'package:daily_record/core/models/edit_check_list_request.dart';
import 'package:daily_record/core/models/edit_check_list_response.dart';
import 'package:daily_record/core/network/dio_client.dart';
import 'package:daily_record/core/utils/error_handler.dart';
import 'package:dio/dio.dart';

class UpdateCheckListService {
  final Dio _dio = DioClient.getInstance();

  // PUT /check-lists/{id}
  Future<EditCheckListResponse> updateCheckLists(
    int id,
    EditCheckListRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.checkListRecord(id),
        data: request.toMap(),
      );

      return EditCheckListResponse.fromMap(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
