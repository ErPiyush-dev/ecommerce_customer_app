import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductService {
  // Saare approved products laana (Home Screen ke liye)
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/all'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Products load nahi ho paaye');
    }
  }

  // Search/Filter ke liye
  Future<List<Product>> searchProducts({
    String? name,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    // Query parameters banate hain - jo null hai wo skip ho jayega
    Map<String, String> queryParams = {};
    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (categoryId != null) queryParams['categoryId'] = categoryId.toString();
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/products/search',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Search fail ho gaya');
    }
  }

  // Ek product ka detail
  Future<Product> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$id'),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Product nahi mila');
    }
  }
}
