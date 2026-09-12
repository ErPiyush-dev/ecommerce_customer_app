class AuthResponse {
  final String token;
  final String role;
  final String name;

  AuthResponse({required this.token, required this.role, required this.name});

  // Backend se aane wale JSON (Map) ko Dart object me convert karta hai
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      role: json['role'],
      name: json['name'],
    );
  }
}
