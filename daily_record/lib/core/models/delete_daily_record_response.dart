class DeleteDailyRecordResponse {
  final String message;
  final int recordId;

  DeleteDailyRecordResponse({
    required this.message,
    required this.recordId,
  });

  factory DeleteDailyRecordResponse.fromMap(Map<String, dynamic> map) {
    return DeleteDailyRecordResponse(
      message: map['message'] ?? '',
      recordId: map['record_id'] ?? 0,
    );
  }
}