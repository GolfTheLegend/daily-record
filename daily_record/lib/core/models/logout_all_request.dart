class LogoutAllRequest {
  final String deviceId;

  LogoutAllRequest({
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
    };
  }

  factory LogoutAllRequest.fromMap(Map<String, dynamic> map) {
    return LogoutAllRequest(
      deviceId: map['device_id'] ?? '',
    );
  }
}
