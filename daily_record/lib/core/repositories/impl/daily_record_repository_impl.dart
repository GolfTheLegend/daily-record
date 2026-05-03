import 'package:daily_record/core/models/create_daily_record_response.dart';
import 'package:daily_record/core/models/daily_record_request.dart';
import 'package:daily_record/core/models/delete_daily_record_response.dart';
import 'package:daily_record/core/models/edit_daily_record_response.dart';
import 'package:daily_record/core/models/get_daily_record_request.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/models/get_status_daily_record_request.dart';
import 'package:daily_record/core/models/get_status_daily_record_response.dart';
import 'package:daily_record/core/repositories/daily_record_repository.dart';
import 'package:daily_record/core/services/create_daily_record_service.dart';
import 'package:daily_record/core/services/delete_daily_record_service.dart';
import 'package:daily_record/core/services/edit_daily_record_service.dart';
import 'package:daily_record/core/services/get_daily_record_service.dart';

class DailyRecordRepositoryImpl implements IDailyRecordRepository {
  final GetDailyRecordService _getService;
  final CreateDailyRecordService _createService;
  final UpdateDailyRecordService _updateService;
  final DeleteDailyRecordService _deleteService;

  DailyRecordRepositoryImpl({
    GetDailyRecordService? getService,
    CreateDailyRecordService? createService,
    UpdateDailyRecordService? updateService,
    DeleteDailyRecordService? deleteService,
  })  : _getService = getService ?? GetDailyRecordService(),
        _createService = createService ?? CreateDailyRecordService(),
        _updateService = updateService ?? UpdateDailyRecordService(),
        _deleteService = deleteService ?? DeleteDailyRecordService();

  @override
  Future<DailyRecordItem> getDailyRecord(int id) {
    return _getService.getDailyRecord(id);
  }

  @override
  Future<GetDailyRecordsResponse> getDailyRecords(
    GetDailyRecordsRequest request,
  ) {
    return _getService.getDailyRecords(request);
  }

  @override
  Future<GetStatusDailyRecordsResponse> getStatusDailyRecords(
    GetStatusDailyRecordsRequest request,
  ) {
    return _getService.getStatusDailyRecords(request);
  }

  @override
  Future<CreateDailyRecordResponse> createDailyRecords(
    DailyRecordsRequest request,
  ) {
    return _createService.createDailyRecords(request);
  }

  @override
  Future<EditDailyRecordResponse> updateDailyRecords(
    int id,
    DailyRecordsRequest request,
  ) {
    return _updateService.updateDailyRecords(id, request);
  }

  @override
  Future<DeleteDailyRecordResponse> deleteDailyRecords(int id) {
    return _deleteService.deleteDailyRecords(id);
  }
}
