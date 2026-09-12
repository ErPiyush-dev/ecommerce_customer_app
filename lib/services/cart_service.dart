import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class CartService {
  final AuthService _authService = AuthService();

  // Token ke saath headers banane ka helper method
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<CartItem> addToCart(int productId, int quantity) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/cart/add'),
      headers: headers,
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return CartItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Cart me add nahi ho paaya');
    }
  }

  Future<List<CartItem>> getCart() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/cart/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CartItem.fromJson(json)).toList();
    } else {
      throw Exception('Cart load nahi ho paaya');
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/cart/update/$cartItemId'),
      headers: headers,
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Quantity update nahi ho paayi');
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/cart/remove/$cartItemId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Item remove nahi ho paaya');
    }
  }
}
