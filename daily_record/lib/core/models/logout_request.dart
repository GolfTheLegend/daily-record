class LogoutRequest {
  final String refreshToken;

  LogoutRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'refresh_token': refreshToken,
    };
  }

  factory LogoutRequest.fromMap(Map<String, dynamic> map) {
    return LogoutRequest(
      refreshToken: map['refresh_token'] ?? '',
    );
  }
}
