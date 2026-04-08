class EditDailyRecordResponse {
  final String message;
  final int recordId;

  EditDailyRecordResponse({
    required this.message,
    required this.recordId,
  });

  factory EditDailyRecordResponse.fromMap(Map<String, dynamic> map) {
    return EditDailyRecordResponse(
      message: map['message'] ?? '',
      recordId: map['record_id'] ?? 0,
    );
  }
}