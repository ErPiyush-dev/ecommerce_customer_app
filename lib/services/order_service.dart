import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class OrderService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<OrderResponse> placeOrder(int addressId) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/orders/place'),
      headers: headers,
      body: jsonEncode({'addressId': addressId}),
    );

    if (response.statusCode == 200) {
      return OrderResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Order place nahi ho paaya');
    }
  }

  Future<List<OrderResponse>> getMyOrders() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/my-orders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrderResponse.fromJson(json)).toList();
    } else {
      throw Exception('Orders load nahi ho paaye');
    }
  }
}
