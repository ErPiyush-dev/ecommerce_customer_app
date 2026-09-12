import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class UserService {

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<UserProfile> getMyProfile() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Profile load nahi ho paayi');
    }
  }

  Future<UserProfile> updateProfile({String? name, String? phoneNumber}) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/users/me'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Profile update nahi ho paayi');
    }
  }
}