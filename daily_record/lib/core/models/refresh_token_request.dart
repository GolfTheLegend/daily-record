class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'refresh_token': refreshToken,
    };
  }

  factory RefreshTokenRequest.fromMap(Map<String, dynamic> map) {
    return RefreshTokenRequest(
      refreshToken: map['refresh_token'] ?? '',
    );
  }
}
