import 'package:flutter/material.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  List<WishlistItem> _wishlistItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WishlistItem> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check karne ke liye ki koi product already wishlist me hai ya nahi (heart icon fill karne ke liye)
  bool isInWishlist(int productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wishlistItems = await _wishlistService.getMyWishlist();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToWishlist(int productId) async {
    try {
      await _wishlistService.addToWishlist(productId);
      await fetchWishlist();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> removeFromWishlist(int wishlistItemId) async {
    try {
      await _wishlistService.removeFromWishlist(wishlistItemId);
      await fetchWishlist();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
