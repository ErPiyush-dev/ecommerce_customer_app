import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get itemCount => _cartItems.length;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCart();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(int productId, int quantity) async {
    try {
      await _cartService.addToCart(productId, quantity);
      await fetchCart(); // Cart list refresh kar dete hain add karne ke baad
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity < 1) return; // Quantity 1 se kam nahi ho sakti
    try {
      await _cartService.updateQuantity(cartItemId, quantity);
      await fetchCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      await fetchCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
