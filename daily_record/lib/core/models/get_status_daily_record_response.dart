class GetStatusDailyRecordsResponse {
  final bool has_record;
  final bool important;
  final int day;
  final int month;
  final int year;

  GetStatusDailyRecordsResponse({
    required this.has_record,
    required this.important,
    required this.day,
    required this.month,
    required this.year,
  });
  factory GetStatusDailyRecordsResponse.fromMap(Map<String, dynamic> map) {
    return GetStatusDailyRecordsResponse(
      has_record: map['has_record'] ?? false,
      important: map['important'] ?? false,
      day: map['day'] ?? 0,
      month: map['month'] ?? 0,
      year: map['year'] ?? 0,
    );
  }
}
