import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class PaymentService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Step A: Razorpay order create karwana
  Future<CreatePaymentResponse> createPaymentOrder(int orderId) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/payments/create/$orderId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return CreatePaymentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Payment order create nahi ho paaya');
    }
  }

  // Step B: Payment verify karwana (Razorpay se success milne ke baad)
  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/payments/verify'),
      headers: headers,
      body: jsonEncode({
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Payment verify nahi ho paaya');
    }
  }
}
