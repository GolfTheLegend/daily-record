import 'package:daily_record/core/models/check_list_request.dart';
import 'package:daily_record/core/models/check_list_response.dart';
import 'package:daily_record/core/models/edit_check_list_request.dart';
import 'package:daily_record/core/models/edit_check_list_response.dart';
import 'package:daily_record/core/repositories/check_list_repository.dart';
import 'package:daily_record/core/services/create_check_list_service.dart';
import 'package:daily_record/core/services/edit_check_list_service.dart';

class CheckListRepositoryImpl implements ICheckListRepository {
  final CreateCheckListService _createService;
  final UpdateCheckListService _updateService;

  CheckListRepositoryImpl({
    CreateCheckListService? createService,
    UpdateCheckListService? updateService,
  })  : _createService = createService ?? CreateCheckListService(),
        _updateService = updateService ?? UpdateCheckListService();

  @override
  Future<CheckListResponse> createCheckLists(
    int id,
    CheckListRequest request,
  ) {
    return _createService.createCheckLists(id, request);
  }

  @override
  Future<EditCheckListResponse> updateCheckLists(
    int id,
    EditCheckListRequest request,
  ) {
    return _updateService.updateCheckLists(id, request);
  }
}
