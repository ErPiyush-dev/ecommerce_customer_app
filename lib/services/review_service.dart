import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ReviewService {

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Bina login ke bhi chalega
  Future<List<Review>> getProductReviews(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reviews/product/$productId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Reviews load nahi ho paaye');
    }
  }

  Future<double> getAverageRating(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reviews/product/$productId/average-rating'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['averageRating'] as num).toDouble();
    } else {
      return 0.0;
    }
  }

  // Login zaroori hai
  Future<void> addReview(int productId, int rating, String comment) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/reviews/add'),
      headers: headers,
      body: jsonEncode({
        'productId': productId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Review add nahi ho paaya');
    }
  }
}