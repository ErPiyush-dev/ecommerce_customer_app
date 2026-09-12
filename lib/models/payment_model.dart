class CreatePaymentResponse {
  final String razorpayOrderId;
  final String razorpayKeyId;
  final double amount;
  final int orderId;

  CreatePaymentResponse({
    required this.razorpayOrderId,
    required this.razorpayKeyId,
    required this.amount,
    required this.orderId,
  });

  factory CreatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePaymentResponse(
      razorpayOrderId: json['razorpayOrderId'],
      razorpayKeyId: json['razorpayKeyId'],
      amount: (json['amount'] as num).toDouble(),
      orderId: json['orderId'],
    );
  }
}
