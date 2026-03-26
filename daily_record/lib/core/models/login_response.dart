class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      accessToken: map['access_token'] ?? '',
      refreshToken: map['refresh_token'] ?? '',
      tokenType: map['token_type'] ?? '',
      expiresIn: map['expires_in'] ?? 0,
    );
  }
}

class UserModel {
  final int id;
  final String email;
  final String username;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
    );
  }
}

class LoginResponse {
  final TokenModel tokens;
  final UserModel user;

  LoginResponse({required this.tokens, required this.user});

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    return LoginResponse(
      tokens: TokenModel.fromMap(map['tokens']),
      user: UserModel.fromMap(map['user']),
    );
  }
}
