class LoginRequest {
  final String username;
  final String password;
  final String deviceId;

  LoginRequest({
    required this.username,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {'username': username, 'password': password, 'device_id': deviceId};
  }

  factory LoginRequest.fromMap(Map<String, dynamic> map) {
    return LoginRequest(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      deviceId: map['device_id'] ?? '',
    );
  }
}
