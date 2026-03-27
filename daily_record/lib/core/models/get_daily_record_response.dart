// get_daily_records_response.dart
class DailyRecordItem {
  final String? activityDetail;
  final String? activityHeader;
  final List<String> dates;
  final String? endTime;
  final int? iconId;
  final int? id;
  final bool? important;
  final int? repeatType;
  final String? startTime;

  DailyRecordItem({
    this.activityDetail,
    this.activityHeader,
    required this.dates,
    this.endTime,
    this.iconId,
    this.id,
    this.important,
    this.repeatType,
    this.startTime,
  });

  factory DailyRecordItem.fromMap(Map<String, dynamic> map) {
    return DailyRecordItem(
      activityDetail: map['activity_detail'],
      activityHeader: map['activity_header'],
      dates: List<String>.from(map['dates'] ?? []),
      endTime: map['end_time'],
      iconId: map['icon_id'],
      id: map['id'],
      important: map['important'],
      repeatType: map['repeat_type'],
      startTime: map['start_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activity_detail': activityDetail,
      'activity_header': activityHeader,
      'dates': dates,
      'end_time': endTime,
      'icon_id': iconId,
      'id': id,
      'important': important,
      'repeat_type': repeatType,
      'start_time': startTime,
    };
  }
}

class GetDailyRecordsResponse {
  final List<DailyRecordItem> data;
  final bool success;

  GetDailyRecordsResponse({required this.data, required this.success});

  factory GetDailyRecordsResponse.fromMap(Map<String, dynamic> map) {
    return GetDailyRecordsResponse(
      data: List<DailyRecordItem>.from(
        (map['data'] ?? []).map((x) => DailyRecordItem.fromMap(x)),
      ),
      success: map['success'] ?? false,
    );
  }
}
