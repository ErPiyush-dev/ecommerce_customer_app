import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AdminService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Category add karna
  Future<void> addCategory(String name, String description) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/categories/admin/add'),
      headers: headers,
      body: jsonEncode({'name': name, 'description': description}),
    );

    if (response.statusCode != 200) {
      throw Exception('Category add nahi ho paayi');
    }
  }

  // Pending (unapproved) products dekhna
  Future<List<Product>> getPendingProducts() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/admin/pending'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Pending products load nahi ho paaye');
    }
  }

  // Product approve karna
  Future<void> approveProduct(int productId) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/products/admin/approve/$productId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Product approve nahi ho paaya');
    }
  }

  // Sabhi products (approved + pending) admin ke liye
  Future<List<Product>> getAllProductsForAdmin() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/admin/all'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Products load nahi ho paaye');
    }
  }

  // Product unapprove karna
  Future<void> unapproveProduct(int productId) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/products/admin/unapprove/$productId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Product unapprove nahi ho paaya');
    }
  }

  Future<void> rejectProduct(int productId, String reason) async {
  final headers = await _getHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/products/admin/reject/$productId'),
    headers: headers,
    body: jsonEncode({'reason': reason}),
  );

  if (response.statusCode != 200) {
    throw Exception('Product reject nahi ho paaya');
  }
}
}
