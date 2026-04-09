class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory RefreshTokenResponse.fromMap(Map<String, dynamic> map) {
    final tokens = map['tokens'] as Map<String, dynamic>;
    return RefreshTokenResponse(
      accessToken: tokens['access_token'] ?? '',
      refreshToken: tokens['refresh_token'] ?? '',
      tokenType: tokens['token_type'] ?? '',
      expiresIn: tokens['expires_in'] ?? 0,
    );
  }
}
