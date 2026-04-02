class CreateDailyRecordResponse {
  final String message;
  final int recordId;

  CreateDailyRecordResponse({
    required this.message,
    required this.recordId,
  });

  factory CreateDailyRecordResponse.fromMap(Map<String, dynamic> map) {
    return CreateDailyRecordResponse(
      message: map['message'] ?? '',
      recordId: map['record_id'] ?? 0,
    );
  }
}