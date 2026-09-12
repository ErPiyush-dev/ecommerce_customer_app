import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../models/seller_order_model.dart';

class SellerProductService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Product>> getMyProducts() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/seller/my-products'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Products load nahi ho paaye');
    }
  }

  // Ab XFile leta hai (File ki jagah) - Web aur Mobile dono par chalega
  Future<String> uploadImage(XFile imageFile) async {
    final token = await _authService.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/products/seller/upload-image'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Bytes read karke bhejte hain - ye Web aur Mobile dono par kaam karta hai
    final bytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'];
    } else {
      throw Exception('Image upload nahi ho paayi');
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
    required int categoryId,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/products/seller/add'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Product add nahi ho paaya');
    }
  }

  Future<List<SellerOrderItem>> getMySales() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/seller/my-sales'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SellerOrderItem.fromJson(json)).toList();
    } else {
      throw Exception('Sales load nahi ho paayi');
    }
  }

  // Product update karna
  Future<void> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
    required int categoryId,
  }) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/products/seller/update/$productId'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Product update nahi ho paaya');
    }
  }

  // Product delete karna
  Future<void> deleteProduct(int productId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/products/seller/delete/$productId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Product delete nahi ho paaya');
    }
  }
}
