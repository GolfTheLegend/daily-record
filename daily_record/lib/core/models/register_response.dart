class RegisterResponse {
  final int id;
  final String email;
  final String username;
  final String role;
  final DateTime createdAt;

  RegisterResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory RegisterResponse.fromMap(Map<String, dynamic> map) {
    return RegisterResponse(
      id: map['id'] ?? 0,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
