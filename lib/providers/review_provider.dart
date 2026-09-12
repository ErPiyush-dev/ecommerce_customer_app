import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<Review> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<Review> get reviews => _reviews;
  double get averageRating => _averageRating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviews(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reviews = await _reviewService.getProductReviews(productId);
      _averageRating = await _reviewService.getAverageRating(productId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReview(int productId, int rating, String comment) async {
    try {
      await _reviewService.addReview(productId, rating, comment);
      await fetchReviews(productId); // List refresh kar dete hain
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
