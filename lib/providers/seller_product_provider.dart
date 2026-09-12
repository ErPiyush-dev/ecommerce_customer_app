import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/seller_product_service.dart';
import '../models/seller_order_model.dart';

class SellerProductProvider extends ChangeNotifier {
  final SellerProductService _service = SellerProductService();

  List<Product> _myProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get myProducts => _myProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myProducts = await _service.getMyProducts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      return await _service.uploadImage(imageFile);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
    required int categoryId,
  }) async {
    try {
      await _service.addProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );
      await fetchMyProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<SellerOrderItem> _mySales = [];
  List<SellerOrderItem> get mySales => _mySales;

  Future<void> fetchMySales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _mySales = await _service.getMySales();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
    required int categoryId,
  }) async {
    try {
      await _service.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );
      await fetchMyProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      await _service.deleteProduct(productId);
      await fetchMyProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
