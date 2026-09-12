import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/admin_service.dart';
import '../services/category_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  List<Product> _pendingProducts = [];
  List<Product> _allProducts = [];
  List<Product> get allProducts => _allProducts;
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  List<Product> get pendingProducts => _pendingProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getAllCategories();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCategory(String name, String description) async {
    try {
      await _adminService.addCategory(name, description);
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPendingProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pendingProducts = await _adminService.getPendingProducts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveProduct(int productId) async {
    try {
      await _adminService.approveProduct(productId);
      await fetchAllProducts(); // Ye line change hui - pehle fetchPendingProducts() tha
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Naya method add karein:
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allProducts = await _adminService.getAllProductsForAdmin();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> unapproveProduct(int productId) async {
    try {
      await _adminService.unapproveProduct(productId);
      await fetchAllProducts(); // List refresh
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectProduct(int productId, String reason) async {
  try {
    await _adminService.rejectProduct(productId, reason);
    await fetchAllProducts();
  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();
  }
}
}
