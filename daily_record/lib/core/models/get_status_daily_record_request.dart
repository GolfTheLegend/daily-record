class GetStatusDailyRecordsRequest {
  final int? day;
  final int? month;
  final int? year;

  GetStatusDailyRecordsRequest({this.day, this.month, this.year});

  Map<String, dynamic> toMap() {
    return {
      if (day != null) 'day': day,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    };
  }
}
