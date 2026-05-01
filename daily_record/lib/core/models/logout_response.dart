class LogoutResponse {
  final String message;
  final int recordId;

  LogoutResponse({
    required this.message,
    required this.recordId,
  });

  factory LogoutResponse.fromMap(Map<String, dynamic>? map) {
    final safeMap = map ?? <String, dynamic>{};
    return LogoutResponse(
      message: safeMap['message'] ?? '',
      recordId: safeMap['record_id'] ?? 0,
    );
  }
}