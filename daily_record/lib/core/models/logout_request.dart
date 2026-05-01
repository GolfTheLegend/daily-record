class LogoutRequest {
  final String refreshToken;
  final String deviceId;

  LogoutRequest({
    required this.refreshToken,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'refresh_token': refreshToken,
      'device_id': deviceId,
    };
  }

  factory LogoutRequest.fromMap(Map<String, dynamic> map) {
    return LogoutRequest(
      refreshToken: map['refresh_token'] ?? '',
      deviceId: map['device_id'] ?? '',
    );
  }
}
