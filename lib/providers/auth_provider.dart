import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String? _token;
  String? _role;
  String? _name;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters - bahar se ye values sirf read kar sakte hain, directly change nahi
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get role => _role;
  String? get name => _name;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // App start hote hi check karta hai ki user pehle se logged in hai ya nahi
  Future<void> checkLoginStatus() async {
    _token = await _authService.getToken();
    _role = await _authService.getRole();
    _name = await _authService.getName();
    _isLoggedIn = _token != null;
    notifyListeners(); // UI ko batata hai "kuch change hua hai, khud ko update kar lo"
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      _token = response.token;
      _role = response.role;
      _name = response.name;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        role: role,
      );
      _token = response.token;
      _role = response.role;
      _name = response.name;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _token = null;
    _role = null;
    _name = null;
    notifyListeners();
  }
}
