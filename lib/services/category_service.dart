import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../utils/constants.dart';

class CategoryService {
  Future<List<Category>> getAllCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/categories/all'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Categories load nahi ho paayi');
    }
  }
}
