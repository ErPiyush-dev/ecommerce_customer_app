class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }
}