class GetStatusDailyRecordItem {
  final bool hasRecord;
  final bool important;
  final int day;
  final int month;
  final int year;

  GetStatusDailyRecordItem({
    required this.hasRecord,
    required this.important,
    required this.day,
    required this.month,
    required this.year,
  });

  factory GetStatusDailyRecordItem.fromMap(Map<String, dynamic> map) {
    return GetStatusDailyRecordItem(
      hasRecord: map['has_record'] ?? false,
      important: map['important'] ?? false,
      day: map['day'] ?? 0,
      month: map['month'] ?? 0,
      year: map['year'] ?? 0,
    );
  }
}

class GetStatusDailyRecordsResponse {
  final List<GetStatusDailyRecordItem> data;
  final bool success;

  GetStatusDailyRecordsResponse({required this.data, required this.success});

  factory GetStatusDailyRecordsResponse.fromMap(Map<String, dynamic> map) {
    return GetStatusDailyRecordsResponse(
      data: List<GetStatusDailyRecordItem>.from(
        (map['data'] ?? []).map((x) => GetStatusDailyRecordItem.fromMap(x)),
      ),
      success: map['success'] ?? false,
    );
  }
}
