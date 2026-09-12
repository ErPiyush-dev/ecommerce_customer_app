import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AddressService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Address>> getMyAddresses() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/addresses/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Address.fromJson(json)).toList();
    } else {
      throw Exception('Addresses load nahi ho paaye');
    }
  }

  Future<Address> addAddress({
    required String fullName,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = false,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/addresses/add'),
      headers: headers,
      body: jsonEncode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2 ?? '',
        'city': city,
        'state': state,
        'pincode': pincode,
        'isDefault': isDefault,
      }),
    );

    if (response.statusCode == 200) {
      return Address.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Address add nahi ho paaya');
    }
  }
}
