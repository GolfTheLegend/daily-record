import 'package:daily_record/core/config/app_config.dart';

class ApiConstants {
  static String get baseUrl => AppConfig.instance.baseUrl;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String getUser = '/auth/me';

  // Daily Records endpoints
  static const String dailyRecords = '/daily-records';
  static const String dailyRecordsStatus = '/daily-records/status';
  static const String createDailyRecord = '/daily-records';
  static String checkListRecord(int id) => '/daily-records/check-list/$id';
  static String dailyRecordById(int id) => '/daily-records/$id';
}
