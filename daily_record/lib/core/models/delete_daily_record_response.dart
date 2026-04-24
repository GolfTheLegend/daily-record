class DeleteDailyRecordResponse {
  final bool success;
  final String error;

  DeleteDailyRecordResponse({
    required this.success,
    required this.error,
  });

  factory DeleteDailyRecordResponse.fromMap(Map<String, dynamic> map) {
    return DeleteDailyRecordResponse(
      success: map['success'] ?? false,
      error: map['error'] ?? '',
    );
  }
}