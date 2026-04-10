class LogoutResponse {
  final String message;
  final int recordId;

  LogoutResponse({
    required this.message,
    required this.recordId,
  });

  factory LogoutResponse.fromMap(Map<String, dynamic> map) {
    return LogoutResponse(
      message: map['message'] ?? '',
      recordId: map['record_id'] ?? 0,
    );
  }
}