class RefreshTokenRequest {
  final String refreshToken;
  final String deviceId;

  RefreshTokenRequest({
    required this.refreshToken,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'refresh_token': refreshToken,
      'device_id': deviceId,
    };
  }

  factory RefreshTokenRequest.fromMap(Map<String, dynamic> map) {
    return RefreshTokenRequest(
      refreshToken: map['refresh_token'] ?? '',
      deviceId: map['device_id'] ?? '',
    );
  }
}
