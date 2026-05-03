import 'package:daily_record/core/models/create_daily_record_response.dart';
import 'package:daily_record/core/models/daily_record_request.dart';
import 'package:daily_record/core/models/delete_daily_record_response.dart';
import 'package:daily_record/core/models/edit_daily_record_response.dart';
import 'package:daily_record/core/models/get_daily_record_request.dart';
import 'package:daily_record/core/models/get_daily_record_response.dart';
import 'package:daily_record/core/models/get_status_daily_record_request.dart';
import 'package:daily_record/core/models/get_status_daily_record_response.dart';

abstract class IDailyRecordRepository {
  Future<DailyRecordItem> getDailyRecord(int id);
  Future<GetDailyRecordsResponse> getDailyRecords(
    GetDailyRecordsRequest request,
  );
  Future<GetStatusDailyRecordsResponse> getStatusDailyRecords(
    GetStatusDailyRecordsRequest request,
  );
  Future<CreateDailyRecordResponse> createDailyRecords(
    DailyRecordsRequest request,
  );
  Future<EditDailyRecordResponse> updateDailyRecords(
    int id,
    DailyRecordsRequest request,
  );
  Future<DeleteDailyRecordResponse> deleteDailyRecords(int id);
}
