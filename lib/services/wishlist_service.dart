import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wishlist_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class WishlistService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<WishlistItem>> getMyWishlist() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/wishlist/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WishlistItem.fromJson(json)).toList();
    } else {
      throw Exception('Wishlist load nahi ho paayi');
    }
  }

  Future<void> addToWishlist(int productId) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/wishlist/add'),
      headers: headers,
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Wishlist me add nahi ho paaya');
    }
  }

  Future<void> removeFromWishlist(int wishlistItemId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/wishlist/remove/$wishlistItemId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Wishlist se remove nahi ho paaya');
    }
  }
}
