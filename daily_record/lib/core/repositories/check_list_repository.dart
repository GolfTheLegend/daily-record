import 'package:daily_record/core/models/check_list_request.dart';
import 'package:daily_record/core/models/check_list_response.dart';
import 'package:daily_record/core/models/edit_check_list_request.dart';
import 'package:daily_record/core/models/edit_check_list_response.dart';

abstract class ICheckListRepository {
  Future<CheckListResponse> createCheckLists(
    int id,
    CheckListRequest request,
  );
  Future<EditCheckListResponse> updateCheckLists(
    int id,
    EditCheckListRequest request,
  );
}
