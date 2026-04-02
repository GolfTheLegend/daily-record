class ApiConstants {
  static const String baseUrl =
      'https://luca-nonbacterial-regenia.ngrok-free.dev/api/v1';

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
  static String dailyRecordById(int id) => '/daily-records/$id';
}
