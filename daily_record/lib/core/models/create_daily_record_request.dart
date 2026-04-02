class CreateDailyRecordsRequest {
  final int iconId;
  final String startTime;
  final String endTime;
  final int repeatType;
  final bool important;
  final String activityHeader;
  final String activityDetail;
  final List<String> dates;

  CreateDailyRecordsRequest({
    required this.iconId,
    required this.startTime,
    required this.endTime,
    required this.repeatType,
    required this.important,
    required this.activityHeader,
    required this.activityDetail,
    required this.dates,
  });

  Map<String, dynamic> toMap() {
    return {
      'icon_id': iconId,
      'start_time': startTime,
      'end_time': endTime,
      'repeat_type': repeatType,
      'important': important,
      'activity_header': activityHeader,
      'activity_detail': activityDetail,
      'dates': dates,
    };
  }
}
