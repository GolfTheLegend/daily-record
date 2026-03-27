class GetDailyRecordsRequest {
  final String? dateFrom;
  final String? dateTo;
  final int? repeatType;
  final bool? important;
  final String? activityHeader;
  final int? limit;
  final int? offset;

  GetDailyRecordsRequest({
    this.dateFrom,
    this.dateTo,
    this.repeatType,
    this.important,
    this.activityHeader,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toMap() {
    return {
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (repeatType != null) 'repeat_type': repeatType,
      if (important != null) 'important': important,
      if (activityHeader != null) 'activity_header': activityHeader,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    };
  }
}
